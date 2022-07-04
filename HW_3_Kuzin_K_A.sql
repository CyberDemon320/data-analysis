/*�������� �����

������� 1. �������� ��� ������� ���������� ��� �����, ����� � ������ ����������.

������� 2. � ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.

	����������� ������ � �������� ������ �� ��������, � ������� ���������� ����������� ������ 300.
��� ������� ����������� ���������� �� ��������������� ������� � �������� ���������. 
	����������� ������, ������� � ���� ���������� � ������ ��������, ������� � ����� ��������, 
������� �������� � ��.

������� 3. �������� ���-5 �����������, ������� ����� � ������ �� �� ����� ���������� ���������� �������.

������� 4. ���������� ��� ������� ���������� 4 ������������� ����������:
	*	���������� ������ � ������ �������;
	*	����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����);
	*	����������� �������� ������� �� ������ ������;
	*	������������ �������� ������� �� ������ ������.
	
������� 5. ��������� ������ �� ������� �������, ��������� ����� �������� ������������ ���� ������� ���, 
����� � ���������� �� ���� ��� � ����������� ���������� �������. ��� ������� ���������� ������������ ��������� ������������.

������� 6. ��������� ������ �� ������� rental � ���� ������ ������ � ������
 (���� rental_date) � ���� �������� (���� return_date), ��������� ��� ������� ���������� ������� 
 ���������� ����, �� ������� �� ���������� ������.

�������������� �����

������� 1. ���������� ��� ������� ������, ������� ��� ��� ����� � ������, � ����� ����� ��������� ������ ������ �� �� �����.

������� 2. ����������� ������ �� ����������� ������� � �������� � ������� ���� ������, ������� �� ���� �� ����� � ������.

������� 3. ���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� ��������. 
���� ���������� ������ ��������� 7 300, �� �������� � ������� ����� ���, ����� ������ ���� �������� ����.
*/

SELECT c.last_name ||' ' ||  c.first_name AS "first_name_and_last_name",
	   a.address,
	   ct.city,
	   co.country 
  FROM customer AS c
       JOIN address AS  a ON c.address_id   = a.address_id 
       JOIN city    AS ct ON a.city_id      = ct.city_id 
       JOIN country AS co ON ct.country_id  = co.country_id  

SELECT c.store_id,
	   COUNT(c.customer_id) AS  "count_of_customer"
  FROM customer AS c 
 GROUP BY store_id 

--explain analyse --62.02
SELECT c.store_id,
	   COUNT(c.customer_id) AS "count_of_customer",
	   t.cit AS "city",
	   st.last_name || ' ' || st.first_name AS "saler_s_name"
  FROM customer AS c 
       JOIN store AS s  ON c.store_id         = s.store_id 
       JOIN staff AS st ON s.manager_staff_id = st.staff_id 
       JOIN (
			SELECT a.address_id AS ai,
				   c2.city      AS cit
			  FROM address AS a 
			       JOIN city AS c2 USiNG(city_id)
		    ) AS t ON s.address_id = t.ai 
 GROUP BY c.store_id, st.last_name, st.first_name, t.cit 
HAVING COUNT(c.customer_id) > 300

--explain analyse  --439.66
SELECT c.last_name || ' ' || c.first_name AS "first_name_and_last_name", 
	   t.kol 
  FROM (
		SELECT customer_id   AS c_id,
			   COUNT(rental_id) AS kol
		  FROM rental AS r 
		 GROUP BY customer_id 
       ) AS t
       JOIN customer AS c ON c.customer_id = t.c_id  
 ORDER BY t.kol DESC 
 LIMIT 5

--explain analyse --719.58

SELECT c.last_name || ' ' || c.first_name AS "customer_s_first_name_and_last_name" ,
	   COUNT(r.rental_id)  AS "coutn_of_film",
	   SUM(p.amount):: INT AS "total_value_spent",
	   MIN(p.amount)       AS "min_spent",
	   MAX(p.amount)       AS "max_spent"
  FROM rental r
       JOIN payment AS  p ON p.rental_id    = r.rental_id 
       JOIN customer AS c ON r.customer_id  = c.customer_id 
GROUP BY c.customer_id--, c.last_name, c.first_name


SELECT c.city  AS "city_1", 
       c2.city AS "city_2"
  FROM city AS c, 
       city AS c2 
 WHERE c.city < c2.city 

--explain analyse --547
SELECT r.customer_id,
	   ROUND(AVG(r.return_date::DATE - r.rental_date::DATE), 2)
  FROM rental r
 WHERE r.return_date IS NOT NULL 
 GROUP BY r.customer_id  
 ORDER BY r.customer_id;

--���
--explain analyse --1327
SELECT f.title        AS "film_name",
	   f.rating       AS "rating",
	   t1.c_name      AS "ganre",
	   f.release_year AS "release_year",
	   l."name"       AS "language_name",
	   t.kol          AS "count_of_rental",
	   t.sum_f        AS "total_value_of_rental" 
  FROM ( 
		SELECT i.film_id          AS fi,
			   COUNT(r.rental_id) AS kol,
			   SUM(amount)        AS sum_f
		  FROM rental AS r 
		       JOIN payment   AS p ON r.rental_id    = p.rental_id 
	           JOIN inventory AS i ON r.inventory_id = i.inventory_id
		 GROUP BY i.film_id
		 ORDER BY film_id 
	    ) AS t
        RIGHT JOIN film f ON t.fi = f.film_id 
        JOIN (
				SELECT fc.film_id AS fi,
					   c."name"   AS c_name
				  FROM film_category AS fc
				       JOIN category c ON fc.category_id = c.category_id 
             ) AS t1 ON f.film_id = t1.fi
        JOIN "language" l ON f.language_id = l.language_id 


--explain analyse --1344
SELECT f.title        AS "film_name",
	   f.rating       AS "rating",
	   t1.c_name      AS "ganre",
	   f.release_year AS "release_year",
	   l."name"       AS "language_name",
	   t.kol          AS "count_of_rental",
	   t.sum_f        AS "total_value_of_rental" 
  FROM ( 
		SELECT i.film_id          AS fi,
			   COUNT(r.rental_id) AS kol,
			   SUM(amount)        AS sum_f
		  FROM rental r 
		       JOIN payment   AS p ON r.rental_id    = p.rental_id 
	           JOIN inventory AS i ON r.inventory_id = i.inventory_id
		 GROUP BY i.film_id
		 ORDER BY film_id 
	   ) AS t
       RIGHT JOIN film f ON t.fi = f.film_id 
	   JOIN (
			SELECT fc.film_id AS fi,
				   c."name"   AS c_name
			  FROM film_category AS fc
			       JOIN category AS c ONw fc.category_id = c.category_id 
	        ) t1 on f.film_id = t1.fi
       JOIN "language" AS l ON f.language_id = l.language_id 
 WHERE t.fi IS NULL

--
--explain analyse --392
SELECT s.staff_id ,
	   t.kol       AS "���-�� ������",
	   t2.own_case AS "������"
  FROM (
		SELECT p.staff_id si,
			   COUNT(p.payment_id) AS kol 
		  FROM rental AS r
		       JOIN payment AS p ON r.rental_id = p.rental_id 
		 GROUP BY p.staff_id 
        ) AS t
        JOIN staff AS s ON t.si = s.staff_id 
        CROSS JOIN LATERAL(
						    SELECT
						      	CASE 
						    		WHEN t.kol > 7300 THEN '��'
						     		ELSE '���'
						     	END "own_case"
						  ) AS t2




