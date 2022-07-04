/*�������� �����

������� 1. �������� SQL-������, ������� ������� ��� ���������� � ������� �� ����������� ��������� �Behind the Scenes�.

������� 2. �������� ��� 2 �������� ������ ������� � ��������� �Behind the Scenes�, 
��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.

������� 3. ��� ������� ���������� ����������, ������� �� ���� � ������ ������� �� ����������� ��������� �Behind the Scenes�.
������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, ���������� � CTE.

������� 4. ��� ������� ���������� ����������, ������� �� ���� � ������ ������� �� ����������� ��������� �Behind the Scenes�.
������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, ���������� � ���������, ������� ���������� 
������������ ��� ������� �������.

������� 5. �������� ����������������� ������������� � �������� �� ����������� ������� � �������� ������ ��� ���������� ������������������ �������������.

������� 6. � ������� explain analyze ��������� ������ �������� ���������� �������� �� ���������� ������� � �������� �� �������:
� ����� ���������� ��� �������� ����� SQL, ������������� ��� ���������� ��������� �������, ����� �������� � ������� ���������� �������;
����� ������� ���������� �������� �������: � �������������� CTE ��� � �������������� ����������.

�������������� �����

������� 1. �������� �� ������ SQL-������.

	* �������� explain analyze ����� �������.
	* ����������� �� �������� �������, ������� ����� ����� � ������� ��.
	* �������� � ����� �������� �� �������� ����� (���� ��� ������ ���������� ������������ � 15�� � �������!).
	* �������� ���������� �������� explain analyze �� ������� ����� ����������������� �������. �������� ����� � explain ����� ���������� �� ������.

������� 2. ��������� ������� �������, �������� ��� ������� ���������� �������� � ������ ��� �������.

������� 3. ��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:

	* ����, � ������� ���������� ������ ����� ������� (� ������� ���-�����-����);
	* ���������� �������, ������ � ������ � ���� ����;
	* ����, � ������� ������� ������� �� ���������� ����� (� ������� ���-�����-����);
	* ����� ������� � ���� ����.
 */

--1
--EXPLAIN ANALYZE --77.50 /0.333
SELECT film_id, 
       title, 
       special_features
  FROM film
 WHERE 'Behind the Scenes' = ANY(special_features)

--2
--EXPLAIN ANALYZE --67.50 /0.38
SELECT film_id, 
       title, 
       special_features
  FROM film 
 WHERE special_features @> ARRAY['Behind the Scenes']

--EXPLAIN ANALYZE --69.99 /0.463
SELECT film_id, 
       title, 
       special_features, 
       array_dims(special_features)
  FROM film 
 WHERE array_position(special_features, 'Behind the Scenes') IS NOT NULL 

--EXPLAIN (format json, ANALYZE) --17572.5 / 1.065
SELECT film_id, 
       title, 
       special_features
FROM (SELECT film_id, title, special_features, 
             generate_subscripts(special_features, 1) AS i
	    FROM film) AS t
 WHERE special_features[i] = 'Behind the Scenes'

--3
--EXPLAIN ANALYZE --817.82 / 7.06
WITH necessary_film AS (
	SELECT f.film_id, 
	       f.title, 
	       f.special_features
	  FROM film AS f 
	 WHERE 'Behind the Scenes' = ANY(special_features)
)
SELECT r.customer_id, 
       COUNT(r.rental_id) 
  FROM rental AS r
       JOIN inventory      AS  i ON r.inventory_id = i.inventory_id
       JOIN necessary_film AS nf ON i.film_id = nf.film_id 
 GROUP BY r.customer_id  
 ORDER BY r.customer_id 

--4
--EXPLAIN ANALYZE -- 685.46 /9.915
SELECT r.customer_id, 
       COUNT(r.rental_id) 
  FROM rental AS r
       JOIN inventory AS i ON r.inventory_id = i.inventory_id
       JOIN (  SELECT f.film_id, 
                      f.title, 
                      f.special_features
		         FROM film AS f 
		        WHERE 'Behind the Scenes' = ANY	(special_features)
	        ) AS nf ON i.film_id = nf.film_id 
 GROUP BY r.customer_id 
 ORDER BY r.customer_id 

 --5
CREATE MATERIALIZED VIEW  count_rental_with_spec_atrib AS (
	SELECT r.customer_id, 
	       COUNT(r.rental_id) 
	  FROM rental AS r
	       JOIN inventory AS i ON r.inventory_id = i.inventory_id
	       JOIN (  SELECT f.film_id, 
	                      f.title, 
	                      f.special_features
			         FROM film AS f 
			        WHERE 'Behind the Scenes' = ANY	(special_features)
		        ) AS nf ON i.film_id = nf.film_id 
	 GROUP BY r.customer_id 
	 ORDER BY r.customer_id 
)
WITH DATA 

REFRESH MATERIALIZED VIEW count_rental_with_spec_atrib;

--6
/*
 1) ����� ��������� � ������� ������� ����� � ������� ���������  any
 2) ������� � ��������������  CTE  �������� �������    
 */


--���

--1
EXPLAIN ANALYSE 
SELECT DISTINCT cu.first_name  || ' ' || cu.last_name AS name, 
	   COUNT(ren.iid) OVER (PARTITION BY cu.customer_id)
  FROM customer cu
       FULL OUTER JOIN 
						(SELECT *, 
						        r.inventory_id AS iid, 
						        inv.sf_string  AS sfs, 
						        r.customer_id  AS cid
						   FROM rental AS r 
						        FULL OUTER JOIN (
												 SELECT *, 
												        UNNEST(f.special_features) AS sf_string
												   FROM inventory AS i
		                                                FULL OUTER JOIN film AS f ON f.film_id = i.film_id
		                                        ) AS inv on r.inventory_id = inv.inventory_id
		                ) AS ren ON ren.cid = cu.customer_id
 WHERE ren.sfs LIKE '%Behind the Scenes%'
 ORDER BY COUNT DESC

/*
1) ������� ���������� ������������ �������  film
2) ����������� ���������� ����������� ������ �� ������� film � ������������ ������� inventory
3) ���������� ������ ���������� � ����� ������� � ��� ������� �� ������� ����� ������ ��������� ��� ������ ������ �������, 
������� � ������ ������� � ������������ ���������� ���������
4) ����� �� ������ � ����������
5) ��������� �� �������  '%Behind the Scenes%'
6) ������������ ���������� inv
7) ����������� ����������  inv
8) ������������ ������� rental
9) ����������� ��������� ������������ ������� customer  �� ���������� ����� � ������ ���������� � �����
������� � ��� ������� �� ������� ����� ������ ��������� ��� ������ ������ �������, ������� ������
10) ��������� ��� �������, �������� ��������� �� ����� ������� � ���������� � ������ ������� ������ ������ �� ������
11) quicksort �� cu.customer_id
12) ������� ��������� 
13) quicksort �� (count(r.inventory_id) OVER (?)) DESC, ((((cu.first_name)::text || ' '::text) || (cu.last_name)::text))
14) ������� ���������� ��������
*/
 
--2
--EXPLAIN ANALYSE --2629.34
SELECT t.staff_id, 
       f.film_id,  
       f.title, 
       p.amount, 
       p.payment_date, 
       c.last_name, 
       c.first_name 
  FROM (
		SELECT *
		  FROM (
				SELECT r.staff_id, 
					   customer_id, 
					   r.inventory_id, 
					   r.rental_date,
					   ROW_NUMBER () OVER (PARTITION BY r.staff_id ORDER BY r.rental_date) AS num
				FROM rental AS r 
		       )AS t
		 WHERE num = 1
        ) AS t
		JOIN customer  AS c ON t.customer_id  = c.customer_id 
		JOIN inventory AS i ON t.inventory_id = i.inventory_id 
		JOIN film      AS f ON i.film_id = f.film_id 
		JOIN payment   AS p ON t.rental_date = p.payment_date 
 
--EXPLAIN  ANALYZE --5428.92
WITH cte AS (
  SELECT s.store_id, r.rental_date::DATE,
         COUNT(r.rental_id) AS count_rent_per_day,
         SUM(p.amount)      AS sum_amount_per_day
    FROM rental    AS r
    JOIN inventory AS i ON r.inventory_id  = i.inventory_id
    JOIN store     AS s ON i.store_id = s.store_id 
    JOIN payment   AS p ON r.rental_id = p.rental_id  
   GROUP BY s.store_id, r.rental_date::date
), count_agr AS(
  SELECT t.store_id,  
         t.rental_date AS day_wiht_max_count, 
         t.max_count
    FROM (
		  SELECT cte.store_id,  
		         cte.rental_date, 
		         cte.count_rent_per_day,
		  		 MAX(cte.count_rent_per_day) OVER (PARTITION BY cte.store_id) AS max_count
		    FROM cte
	     ) AS t
	   WHERE t.count_rent_per_day = t.max_count
), sum_agr AS (
	SELECT t.store_id,  t.rental_date AS day_wiht_min_sum, t.min_sum
      FROM (
			  SELECT cte.store_id,  
			         cte.rental_date, 
			         cte.sum_amount_per_day,
			  		 MIN(cte.sum_amount_per_day) OVER (PARTITION BY cte.store_id) AS min_sum
			    FROM cte
	       ) AS t
	   WHERE t.sum_amount_per_day = t.min_sum
)
SELECT ca.store_id,  ca.day_wiht_max_count, ca.max_count , sa.day_wiht_min_sum, sa.min_sum 
  FROM count_agr    AS ca
       JOIN sum_agr AS sa ON ca.store_id = sa.store_id 




