/*
  1) В каких городах больше одного аэропорта?
  2) В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
  3) Вывести 10 рейсов с максимальным временем задержки вылета.
  4) Были ли брони, по которым не были получены посадочные талоны?
  5) Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
  Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого 
  аэропорта на каждый день. Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже 
  вылетело из данного аэропорта на этом или более ранних рейсах в течении дня.
  6) Найдите процентное соотношение перелетов по типам самолетов от общего количества.
  7) Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
  8) Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной 
  дальностью перелетов  в самолетах, обслуживающих эти рейсы *
 */


--1
--EXPLAIN ANALYZE 
SELECT   city->>'ru' AS city, 
         COUNT(airport_name->>'ru') AS count_airoports
FROM     airports_data ad 
GROUP BY city->>'ru'
HAVING   COUNT(airport_name ->>'ru') > 1
/*ЛОГИКА
 * В таблице airoports_data группируем по городам и выбираем те города,
 * в которых число аэропортов больше 1
 */



--2

--EXPLAIN ANALYZE --1785
SELECT   aird.airport_name->>'ru' AS "Название аэропорта",
	     ad.model ->> 'ru' AS "Назв. самолета с макс. дальн. перел"
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
/* ЛОГИКА
 * К таблице flights присоединяем подзапрос ad по ключу f.arrival_airport = aird.airport_code
 * Из подзапроса ad мы узнаем  типы самолетов в максимальной дальностью полета
 * Группируем по аэропортам
 */

--3
--EXPLAIN ANALYZE
SELECT   flight_id AS "рейсы с макс. вр. задержки вылета", 
         actual_departure - scheduled_departure AS "Задержка вылета"
FROM     flights AS f 
WHERE    actual_departure IS NOT NULL
ORDER BY actual_departure - scheduled_departure DESC
LIMIT    10
/*ЛОГИКА
 * Из таблички flights берем данные, в которых  actual_departure не null, т.к. самолет может еще не вылететь
 * и сортируем по времени задержки по убыванию
 * берем первые 10 рейсов 
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
        
/* ЛОГИКА:
 *    в подзапросе находим количество билетов по броням 
 *    в основном запросе выбираем только те, в которых не было получено ни одного билета
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
/*ЛОГИКА:
 *     В cte necessary_flights выбираем только те рейсы, которые уже прошли или уже идут 
 *     В cte flights_with_seats соединяем necessary_flights с табличкой seats  и считаем сколько всего мест в самолете
 *     В cte not_free_sets к таблице boarding_passes присоединяем таблицу нужных рейсов necessary_flights и ищем 
 * сколько мест занято
 *     В cte first_task таблице  flights_with_seats присоединяем таблицу not_free_sets и  считаем показатели 
 *     В cte second_task в подзапросе t  в окне считаем количесво человек, вывезенных из аэропорта на каждый день
 *                       в основном запросе шруппируем одинаковые значения 
 *     В основном запросе присоединяем  first_task и first_task и выводим основныке показатели 
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
/*ЛОГИКА
 * в подзапросе t группирую по типу самолета и считаю количество перелетов с каждым типом
 * В select считаю процент перелетов по типам самолетов
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

/*ответ: нет
 * ЛОГИКА
 *     В CTE small_ticket_flights я группирую по flight_id, fare_conditions, amount чтобы убрать лишние значения
 *     Далее в CTE ecomomy_tickets и business_tickets я разделяю таблицу small_ticket_flights на 2 билеты эконом 
 * класса и билеты бизнес класса
 *     Далее в CTE flights_where_economy_more_business я их соединяю и проверяю, есть ли среди них такие, что цена эконом класса больше цены бизнес класса
 *     Далее к таблице flights присоединяю таблицы  flights_where_economy_more_business и airports_data и вывожу города, являющиеся решением задачи
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
	       WHEN acos(sind(cd.latitude_A) * sind(ca.latitude_B) + cosd(cd.latitude_A) * cosd(ca.latitude_B) * cosd(cd.longitude_A - ca.longitude_B)) * 6371 < ad2."range" THEN 'Долетит'
	       ELSE 'Не долетит'
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
         
/*ЛОГИКА
 * В CTE coords_departure находим координаты города отправления
 * В CTE coords_arrival находим координаты города прибытия 
 * В основном запросе к таблице flights присоединяем эти CTE и таблицу aircrafts_data для нахождения поля range
 * Вычисляем фактическое расстояние между городами и сравниваем с максимальной длиной полета самолета
 * Делаем вывод долетит или нет
 */ 
