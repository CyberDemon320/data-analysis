/*�������� �����:
������� 1. �������� ���������� �������� ������� �� ������� �������.

������� 2. ����������� ������ �� ����������� �������, ����� ������ ������� ������ �� ������, 
�������� ������� ���������� �� �L� � ������������� �� �a�, � �������� �� �������� ��������.

������� 3. �������� �� ������� �������� �� ������ ������� ���������� �� ��������, 
������� ����������� � ���������� � 17 ���� 2005 ���� �� 19 ���� 2005 ���� ������������ � 
��������� ������� ��������� 1.00. ������� ����� ������������� �� ���� �������.


������� 4. �������� ���������� � 10-�� ��������� �������� �� ������ �������.

������� 5. �������� ��������� ���������� �� �����������:
	������� � ��� (� ����� ������� ����� ������)
	����������� �����
	����� �������� ���� email
	���� ���������� ���������� ������ � ���������� (��� �������)
	������ ������� ������� ������������ �� ������� �����.
	
������� 6. �������� ����� �������� ������ �������� �����������, ����� ������� KELLY ��� WILLIE. 
��� ����� � ������� � ����� �� �������� �������� ������ ���� ���������� � ������ �������.

�������������� �����:

������� 1.�������� ����� �������� ���������� � �������, � ������� ������� �R� � 
��������� ������ ������� �� 0.00 �� 3.00 ������������, � ����� ������ c ��������� �PG-13� � 
���������� ������ ������ ��� ������ 4.00.

������� 2. �������� ���������� � ��� ������� � ����� ������� ��������� ������.

������� 3. �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
	� ������ ������� ������ ���� ��������, ��������� �� @,
	�� ������ ������� ������ ���� ��������, ��������� ����� @.

������� 4. ����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
������ ����� ������ ���� ���������, ��������� ���������.
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

SELECT concat(last_name, ' ', first_name) AS "������� � ���", 
       email AS "���������� �����", 
	   CHARACTER_LENGTH(email) AS "����� Email", 
	   last_update AS "����"  
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





