/*
  1) � ����� ������� ������ ������ ���������?
  2) � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?
  3) ������� 10 ������ � ������������ �������� �������� ������.
  4) ���� �� �����, �� ������� �� ���� �������� ���������� ������?
  5) ������� ���������� ��������� ���� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
  �������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� 
  ��������� �� ������ ����. �.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� 
  �������� �� ������� ��������� �� ���� ��� ����� ������ ������ � ������� ���.
  6) ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.
  7) ���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?
  8) ��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ 
  ���������� ���������  � ���������, ������������� ��� ����� *
 */


--1
--EXPLAIN ANALYZE 
SELECT   city->>'ru' AS city, 
         COUNT(airport_name->>'ru') AS count_airoports
FROM     airports_data ad 
GROUP BY city->>'ru'
HAVING   COUNT(airport_name ->>'ru') > 1
/*������
 * � ������� airoports_data ���������� �� ������� � �������� �� ������,
 * � ������� ����� ���������� ������ 1
 */



--2

--EXPLAIN ANALYZE --1785
SELECT   aird.airport_name->>'ru' AS "�������� ���������",
	     ad.model ->> 'ru' AS "����. �������� � ����. �����. �����"
FROM     flights AS f 
		 JOIN (
			SELECT aircraft_code,
			       model,
			       "range"
			FROM   aircrafts_data
			WHERE  "range" = (
							SELECT MAX ("range")
							FROM   aircrafts_data ad2 ) 
		 ) AS ad ON f.aircraft_code = ad.aircraft_code 
         JOIN airports_data AS aird ON f.arrival_airport = aird.airport_code
GROUP BY aird.airport_code, ad."range", ad.model
/* ������
 * � ������� flights ������������ ��������� ad �� ����� f.arrival_airport = aird.airport_code
 * �� ���������� ad �� ������  ���� ��������� � ������������ ���������� ������
 * ���������� �� ����������
 */

--3
--EXPLAIN ANALYZE
SELECT   flight_id AS "����� � ����. ��. �������� ������", 
         actual_departure - scheduled_departure AS "�������� ������"
FROM     flights AS f 
WHERE    actual_departure IS NOT NULL
ORDER BY actual_departure - scheduled_departure DESC
LIMIT    10
/*������
 * �� �������� flights ����� ������, � �������  actual_departure �� null, �.�. ������� ����� ��� �� ��������
 * � ��������� �� ������� �������� �� ��������
 * ����� ������ 10 ������ 
 */


--4  
--EXPLAIN ANALYZE 
SELECT COUNT(*)
  FROM (
		SELECT COUNT(bp.boarding_no) AS count_in_book
		  FROM bookings AS b
		       JOIN tickets AS t ON b.book_ref = t.book_ref 
		       LEFT JOIN boarding_passes AS bp ON t.ticket_no = bp.ticket_no 
		GROUP BY b.book_ref 
		) AS t  
WHERE count_in_book = 0
        
/* ������:
 *    � ���������� ������� ���������� ������� �� ������ 
 *    � �������� ������� �������� ������ ��, � ������� �� ���� �������� �� ������ ������
 */
 
--5 
EXPLAIN ANALYZE --1 239 473.83
WITH necessary_flights AS (   
	SELECT flight_id, 
	       aircraft_code,
	       actual_departure,
	       departure_airport 
	  FROM flights AS f
	 WHERE status = 'Departed'
	    OR status = 'Arrived'
), flights_with_seats AS (
	SELECT nf.flight_id,
	       COUNT(s.seat_no) AS all_palce_in_flight
	  FROM necessary_flights AS nf
	       JOIN seats AS s  ON nf.aircraft_code = s.aircraft_code
  GROUP BY nf.flight_id
), not_free_sets AS (
	SELECT bp.flight_id,
	       COUNT(bp.seat_no) AS not_free_seats_on_flight
	  FROM boarding_passes AS bp 
	       JOIN necessary_flights AS nf ON bp.flight_id = nf.flight_id 
  GROUP BY bp.flight_id
), first_task AS (
  SELECT fws.flight_id, 
 	     fws.all_palce_in_flight - nfs.not_free_seats_on_flight AS free_seats_on_flight,
         100 - ROUND((nfs.not_free_seats_on_flight::NUMERIC/ fws.all_palce_in_flight) * 100, 2) AS "percent"
    FROM flights_with_seats AS fws
         JOIN not_free_sets AS nfs ON fws.flight_id = nfs.flight_id
), second_task AS (
 SELECT t.flight_id, 
        t.count_people_from_airoport 
 FROM (
	SELECT nf.flight_id,	       
	       COUNT(nf.flight_id) OVER (PARTITION BY nf.departure_airport, nf.actual_departure::date  ORDER BY nf.actual_departure) AS count_people_from_airoport
	FROM necessary_flights AS nf
	      JOIN ticket_flights  AS tf  ON nf.flight_id = tf.flight_id 
	      JOIN boarding_passes AS bp2 ON tf.ticket_no = bp2.ticket_no 
	                                 AND tf.flight_id = bp2.flight_id 
) AS t 	                               
GROUP BY t.flight_id, t.count_people_from_airoport 
)
SELECT ft.flight_id, 
       ft.free_seats_on_flight,
       ft."percent",
       st.count_people_from_airoport
  FROM first_task AS ft
       JOIN second_task AS st ON ft.flight_id = st.flight_id 
ORDER BY flight_id 
--34 426
/*������:
 *     � cte necessary_flights �������� ������ �� �����, ������� ��� ������ ��� ��� ���� 
 *     � cte flights_with_seats ��������� necessary_flights � ��������� seats  � ������� ������� ����� ���� � ��������
 *     � cte not_free_sets � ������� boarding_passes ������������ ������� ������ ������ necessary_flights � ���� 
 * ������� ���� ������
 *     � cte first_task �������  flights_with_seats ������������ ������� not_free_sets �  ������� ���������� 
 *     � cte second_task � ���������� t  � ���� ������� ��������� �������, ���������� �� ��������� �� ������ ����
 *                       � �������� ������� ���������� ���������� �������� 
 *     � �������� ������� ������������  first_task � first_task � ������� ��������� ���������� 
 */

--6
--EXPLAIN ANALYZE 
SELECT aircraft_code, 
       ROUND(count_aircraft::NUMERIC  / (SELECT count(*) FROM flights f2), 3) * 100 AS "percent"
FROM   (
		SELECT   aircraft_code, 
			     count(flight_id) AS count_aircraft
		FROM     flights f 
		GROUP BY aircraft_code 
) AS t
/*������
 * � ���������� t ��������� �� ���� �������� � ������ ���������� ��������� � ������ �����
 * � select ������ ������� ��������� �� ����� ���������
 */


--7
--EXPLAIN ANALYZE --79513
WITH small_ticket_flights AS (
	  SELECT flight_id, 
	         fare_conditions, 
	         amount
	    FROM ticket_flights AS tf 
	GROUP BY flight_id, fare_conditions, amount  
	ORDER BY flight_id, fare_conditions, amount DESC
), ecomomy_tickets AS (
	SELECT flight_id, 
	       fare_conditions, 
	       amount
	  FROM small_ticket_flights 
	 WHERE fare_conditions = 'Economy'
), business_tickets AS (
	SELECT flight_id, 
	       fare_conditions, 
	       amount
	  FROM small_ticket_flights 
	 WHERE fare_conditions = 'Business'
), flights_where_economy_more_business AS (
	SELECT DISTINCT bt.flight_id
	  FROM business_tickets AS bt
		   JOIN ecomomy_tickets AS et ON bt.flight_id = et.flight_id 
     WHERE bt.amount < et.amount 
)
SELECT ad.city ->> 'ru' AS "city"
  FROM flights AS f
       JOIN flights_where_economy_more_business AS femb ON f.flight_id = femb.flight_id 
       JOIN airports_data                       AS ad   ON f.arrival_airport = ad.airport_code 

/*�����: ���
 * ������
 *     � CTE small_ticket_flights � ��������� �� flight_id, fare_conditions, amount ����� ������ ������ ��������
 *     ����� � CTE ecomomy_tickets � business_tickets � �������� ������� small_ticket_flights �� 2 ������ ������ 
 * ������ � ������ ������ ������
 *     ����� � CTE flights_where_economy_more_business � �� �������� � ��������, ���� �� ����� ��� �����, ��� ���� ������ ������ ������ ���� ������ ������
 *     ����� � ������� flights ����������� �������  flights_where_economy_more_business � airports_data � ������ ������, ���������� �������� ������
 * 
 */

--8 
--EXPLAIN ANALYZE 
WITH coords_departure AS (
	 SELECT f.flight_id, 
	        departure_airport, 
	        ad.coordinates[0] AS longitude_A, 
	        ad.coordinates[1] AS latitude_A,
	        ad.airport_name ->> 'ru' AS departure_airport_name,
	        ad.city ->> 'ru' AS departure_city
	 FROM flights AS f 
	      JOIN airports_data AS ad ON  f.departure_airport = ad.airport_code 
), coords_arrival AS (
     SELECT f.flight_id, 
	        arrival_airport , 
	        ad.coordinates[0] AS longitude_B, 
	        ad.coordinates[1] AS latitude_B,
	        ad.airport_name ->> 'ru' AS arrival_airport_name, 
	        ad.city ->> 'ru' AS arrival_city
	 FROM flights AS f 
	      JOIN airports_data AS ad ON  f.arrival_airport = ad.airport_code
)
SELECT *
FROM (
SELECT f.departure_airport, 
       cd.departure_airport_name,
       cd.departure_city,
       f.arrival_airport, 
       ca.arrival_airport_name,
       ca.arrival_city,
       round(acos(sind(cd.latitude_A) * sind(ca.latitude_B) + cosd(cd.latitude_A) * cosd(ca.latitude_B) * cosd(cd.longitude_A - ca.longitude_B)) * 6371) AS "length",
       ad2."range",
 	   CASE 
	       WHEN acos(sind(cd.latitude_A) * sind(ca.latitude_B) + cosd(cd.latitude_A) * cosd(ca.latitude_B) * cosd(cd.longitude_A - ca.longitude_B)) * 6371 < ad2."range" THEN '�������'
	       ELSE '�� �������'
	    END AS stat           
  FROM flights AS f
       JOIN coords_departure AS cd ON f.flight_id = cd.flight_id
       JOIN coords_arrival AS ca ON f.flight_id = ca.flight_id 
       JOIN aircrafts_data AS ad2 ON f.aircraft_code  = ad2.aircraft_code
) AS t
GROUP BY t.departure_airport, 
         t.departure_airport_name,
         t.departure_city,
         t.arrival_airport, 
         t.arrival_airport_name,
         t.arrival_city,
         t."range",
         t."length",
         t.stat
         
/*������
 * � CTE coords_departure ������� ���������� ������ �����������
 * � CTE coords_arrival ������� ���������� ������ �������� 
 * � �������� ������� � ������� flights ������������ ��� CTE � ������� aircrafts_data ��� ���������� ���� range
 * ��������� ����������� ���������� ����� �������� � ���������� � ������������ ������ ������ ��������
 * ������ ����� ������� ��� ���
 */ 
