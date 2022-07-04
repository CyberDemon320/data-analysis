/*Основная часть:
Задание 1. Выведите уникальные названия городов из таблицы городов.

Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, 
названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.

Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, 
которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и 
стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.


Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.

Задание 5. Выведите следующую информацию по покупателям:
	Фамилия и имя (в одной колонке через пробел)
	Электронная почта
	Длину значения поля email
	Дату последнего обновления записи о покупателе (без времени)
	Каждой колонке задайте наименование на русском языке.
	
Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. 
Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.

Дополнительная часть:

Задание 1.Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и 
стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и 
стоимостью аренды больше или равной 4.00.

Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма.

Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
	в первой колонке должно быть значение, указанное до @,
	во второй колонке должно быть значение, указанное после @.

Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
первая буква должна быть заглавной, остальные строчными.
*/

SELECT DISTINCT city
  FROM city;

SELECT DISTINCT city
  FROM city
 WHERE city LIKE 'L%a' 
   AND city NOT ilike '% %';

SELECT customer_id, 
       staff_id, 
       rental_id, 
       amount, 
       payment_date 
  FROM payment p 
 WHERE (payment_date::DATE BETWEEN '2005-06-17' AND '2005-06-19')
   AND amount > 1.00
 ORDER BY payment_date;

SELECT payment_id, 
       payment_date, 
       amount 
  FROM payment p 
 ORDER BY payment_date DESC
 LIMIT 10;

SELECT concat(last_name, ' ', first_name) AS "Фамилия и имя", 
       email AS "Элктронная почта", 
	   CHARACTER_LENGTH(email) AS "Длина Email", 
	   last_update AS "Дата"  
  FROM customer c ;

SELECT LOWER(last_name) AS "last name", 
	   LOWER(first_name) AS "first name", 
	   active
  FROM customer c 
 WHERE active = 1 
   AND (first_name = 'KELLY' OR first_name = 'WILLIE');

SELECT film_id, 
       title, 
       description, 
       rating, 
       rental_rate 
  FROM film
 WHERE (rating = 'R' AND (rental_rate <= 3.00 AND rental_rate >= 0.00)) 
    OR (rating = 'PG-13' AND rental_rate >= 4.00);
	 
SELECT film_id, 
       title, 
       description
  FROM film f 
 ORDER BY LENGTH (description) DESC;

SELECT customer_id, 
	   email, 
	   split_part(email, '@', 1) AS "Email before @", 
	   split_part(email, '@', 2) AS "Email after @" 
  FROM customer c 

SELECT customer_id, 
	   email, 
	   CONCAT(UPPER(SUBSTRING(split_part(email, '@', 1) FROM 1 FOR 1 )),
       SUBSTRING(LOWER(split_part(email, '@', 1)) FROM 1 FOR LENGTH(split_part(email, '@', 1)))) AS "Email before @", 
	   CONCAT(UPPER(SUBSTRING(split_part(email, '@', 2) FROM 1 FOR 1 )),
	   SUBSTRING(LOWER(split_part(email, '@', 2)) FROM 1 FOR LENGTH(split_part(email, '@', 2)))) AS "Email after @"
  FROM customer c 





