/*Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:

	* Пронумеруйте все платежи от 1 до N по дате
	* Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
	* Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка 
	должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
	* Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
	так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
	Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и 
стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

Дополнительная часть

Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года
с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа 
получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, 
которые в день проведения акции получили скидку.

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм. 
 */

--EXPLAIN ANALYSE  --6047.56 
SELECT  customer_id , 
        payment_id ,
        payment_date, 
		ROW_NUMBER() OVER (ORDER BY payment_date )                                 AS column_1,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date)         AS column_2,
		SUM(amount)  OVER (PARTITION BY customer_id ORDER BY payment_date, amount) AS column_3,
		DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY amount desc)          AS column_4
  FROM  payment 

--EXPLAIN ANALYZE  --1721.51
SELECT customer_id, 
       payment_id , 
       payment_date,  
       LAG(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) AS previous,
 	   amount
  FROM payment

--EXPLAIN ANALYZE  --1761.63
SELECT customer_id, 
       payment_id , 
       payment_date, 
       amount,
       amount - LEAD(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) AS current_dif_next
  FROM payment

--EXPLAIN ANALYZE   -- 2729.22 
WITH first_val AS (
      SELECT customer_id, 
             payment_id,
	         FIRST_VALUE(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date desc) AS last_rental,
	         amount
	    FROM payment
)
SELECT fv.customer_id, 
       fv.payment_id, 
       fv.last_rental, 
       fv.amount 
  FROM first_val AS fv
       JOIN payment AS p ON fv.payment_id = p.payment_id 
 WHERE p.customer_id  = fv.customer_id  
   AND p.payment_id   = fv.payment_id
   AND p.payment_date = fv.last_rental 
   
   
--доп

--EXPLAIN ANALYZE --450.64
WITH sum_day AS (
	SELECT staff_id, 
	       payment_date:::DATE, 
	       SUM(amount) AS sum_amount
	  FROM payment AS p2 
	 WHERE DATE_TRUNC('month', payment_date::DATE) = '2005.08.01'::DATE 
	 GROUP BY staff_id, payment_date::DATE
	 ORDER BY staff_id, payment_date::DATE
)
 SELECT staff_id, 
	    payment_date, 
	    sum_amount,
 	    SUM(sum_amount) OVER (PARTITION BY staff_id ORDER BY staff_id, payment_date)
 FROM sum_day
 
 WITH sale_day AS (
 	SELECT customer_id, 
 	       payment_date,
           ROW_NUMBER() OVER (ORDER BY payment_date) AS payment_number
 	  FROM payment AS p 
 	 WHERE payment_date::DATE = '2005.08.20'::DATE
 )
 SELECT customer_id, 
        payment_date,
        payment_number
   FROM sale_day
  WHERE payment_number % 100 = 0
 

 
--EXPLAIN ANALYZE

	 	
SELECT * FROM country c  	

--EXPLAIN ANALYZE --3214.43
SELECT t.country, 
       t.cust_max_rental_film,
       t.cust_max_sum_amount,
       t.cust_last_rental
FROM (
	SELECT   c3.country,
	        FIRST_VALUE(c.first_name) OVER (PARTITION BY c3.country ORDER BY count_paymant DESC ) ||
	        ' ' || FIRST_VALUE(c.last_name) OVER (PARTITION BY c3.country ORDER BY count_paymant DESC )   AS cust_max_rental_film,
	        FIRST_VALUE(c.first_name) OVER (PARTITION BY c3.country ORDER BY sum_amount DESC ) ||
	        ' ' || FIRST_VALUE(c.last_name) OVER (PARTITION BY c3.country ORDER BY sum_amount DESC )      AS cust_max_sum_amount,
	        FIRST_VALUE(c.first_name) OVER (PARTITION BY c3.country ORDER BY last_date_rental DESC ) ||
	        ' ' ||FIRST_VALUE(c.last_name) OVER (PARTITION BY c3.country ORDER BY last_date_rental DESC ) AS cust_last_rental
	 FROM (
		 SELECT t.customer_id      AS customer_id, 
		        t.count_paymant    AS count_paymant, 
		        t.sum_amount       AS sum_amount, 
		        t.last_date_rental AS last_date_rental
		 FROM (
		        SELECT customer_id,
				 	COUNT(payment_id) OVER (PARTITION BY customer_id)                                    AS count_paymant,
				 	SUM (amount) OVER (PARTITION BY customer_id)                                         AS sum_amount,
				 	FIRST_VALUE(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date desc) AS last_date_rental
			 	FROM payment 
		 ) AS t
		 GROUP BY t.customer_id, t.count_paymant, t.sum_amount, t.last_date_rental
	) AS t
	JOIN customer AS c ON t.customer_id  = c.customer_id 
	JOIN address AS a ON c.address_id = a.address_id 
	JOIN city AS c2 ON a.city_id = c2.city_id 
	JOIN country AS c3 ON c2.country_id = c3.country_id  
) AS t
GROUP BY t.country, t.cust_max_rental_film,
         t.cust_max_sum_amount,
         t.cust_last_rental
ORDER BY t.country 
	 	
	 	
	 	
	 	
	 	