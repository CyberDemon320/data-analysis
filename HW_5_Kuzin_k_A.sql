/*������� 1. �������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:

	* ������������ ��� ������� �� 1 �� N �� ����
	* ������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
	* ���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� 
	������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
	* ������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� 
	���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
	����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.

������� 2. � ������� ������� ������� �������� ��� ������� ���������� ��������� ������� � 
��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.

������� 3. � ������� ������� ������� ����������, �� ������� ������ ��������� ������ ���������� ������ ��� ������ ��������.

������� 4. � ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.

�������������� �����

������� 1. � ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ������ 2005 ����
� ����������� ������ �� ������� ���������� � �� ������ ���� ������� (��� ����� �������) � ����������� �� ����.

������� 2. 20 ������� 2005 ���� � ��������� ��������� �����: ���������� ������� ������ ������� 
������� �������������� ������ �� ��������� ������. � ������� ������� ������� �������� ���� �����������, 
������� � ���� ���������� ����� �������� ������.

������� 3. ��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
� ����������, ������������ ���������� ���������� �������;
� ����������, ������������ ������� �� ����� ������� �����;
� ����������, ������� ��������� ��������� �����. 
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
   
   
--���

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
	 	
	 	
	 	
	 	
	 	