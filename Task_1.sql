/* Задание 1
	Составьте SQL-запросы. Придумайте, как оценить показатели, и напишите 
запросы для расчёта придуманных метрик. Представьте, что в вашем 
распоряжении есть все ресурсы по сбору статистики. Если вам необходимы 
дополнительный данные, то опишите, чего не хватает в базе, чтобы посчитать
нужные метрики. Укажите, какой диалект SQL вы используете.
	1. Топ 10 тасок месяца, с которыми потенциально что-то не так
	2. Топ страниц (разделов) куда в рамках сессии переходит 
	пользователь из «Учебного календаря»
	3. "Цепляемость" и "крутость" курса. Нужна какая-то метрика, 
	которая при наличии трёх-четырёх уроков курса позволит 
	сравнить этот курс по "Цепляемости" с другими курсами.
  
 */





CREATE TABLE all_data(
cust_id         INT,
session_id      CHAR(50),
name_page       CHAR(50),
time_transition TIMESTAMP
)

--Программа обучения, План на сегодня, Успеваемость, Домашняя школа, Задания, Рекомендации и скидки, Занятие, Корзина, Учебный календарь, и много другого
--2
   INSERT INTO all_data(cust_id, session_id, name_page, time_transition)
		VALUES (1, 1, 'Учебный календарь',     '2022-07-08 16:24:23'::TIMESTAMP),
		       (1, 1, 'Успеваемость',          '2022-07-08 16:24:33'::TIMESTAMP),
		       (1, 1, 'План на сегодня',       '2022-07-08 16:24:43'::TIMESTAMP),
		       (1, 1, 'Программа обучения',    '2022-07-08 16:24:53'::TIMESTAMP),
		       (1, 1, 'Успеваемость',          '2022-07-08 16:25:03'::TIMESTAMP),
		       (1, 1, 'Домашняя школа',        '2022-07-08 16:25:13'::TIMESTAMP),
		       (1, 1, 'Занятие',               '2022-07-08 16:25:23'::TIMESTAMP),
		       (1, 1, 'Учебный календарь',     '2022-07-08 16:25:33'::TIMESTAMP),
		       (1, 1, 'Задания',               '2022-07-08 16:25:43'::TIMESTAMP),
		       (2, 1, 'Учебный календарь',     '2022-07-08 17:24:23'::TIMESTAMP),
		       (2, 1, 'Успеваемость',          '2022-07-08 17:24:33'::TIMESTAMP),
		       (2, 1, 'Рекомендации и скидки', '2022-07-08 17:24:43'::TIMESTAMP),
		       (2, 1, 'Учебный календарь',     '2022-07-08 17:24:53'::TIMESTAMP),
		       (2, 1, 'Занятие',               '2022-07-08 17:25:03'::TIMESTAMP),
		       (2, 1, 'Домашняя школа',        '2022-07-08 17:25:13'::TIMESTAMP),
		       (2, 1, 'Корзина',               '2022-07-08 17:25:23'::TIMESTAMP),
		       (2, 2, 'Учебный календарь',     '2022-07-08 17:24:33'::TIMESTAMP),
		       (2, 2, 'Корзина',               '2022-07-08 17:24:43'::TIMESTAMP),
		       (2, 2, 'Успеваемость',          '2022-07-08 17:24:53'::TIMESTAMP),
		       (2, 2, 'План на сегодня',       '2022-07-08 17:25:03'::TIMESTAMP),
		       (2, 2, 'Учебный календарь',     '2022-07-08 17:25:13'::TIMESTAMP),
		       (2, 2, 'Домашняя школа',        '2022-07-08 17:25:33'::TIMESTAMP),
		       (3, 1, 'Учебный календарь',     '2022-07-08 17:26:13'::TIMESTAMP),
		       (3, 1, 'Домашняя школа',        '2022-07-08 17:27:13'::TIMESTAMP),
		       (3, 1, 'Корзина',               '2022-07-08 17:27:33'::TIMESTAMP),
		       (3, 1, 'Успеваемость',          '2022-07-08 17:28:33'::TIMESTAMP),
		       (3, 1, 'Корзина',               '2022-07-08 17:29:33'::TIMESTAMP)
       

--EXPLAIN ANALYZE  --cost = 28.10 time = 0.073
WITH norm_data AS (
	SELECT cust_id, 
	       session_id, 
	       name_page, 
	       time_transition
	  FROM all_data 
	 WHERE cust_id         IS NOT NULL 
	   AND session_id      IS NOT NULL
	   AND name_page       IS NOT NULL 
	   AND time_transition IS NOT NULL
)
SELECT next_page, 
       COUNT(cust_id) AS count_
  FROM (
	   SELECT cust_id, 
              session_id, 
              name_page, 
              time_transition,
	          LEAD(name_page) OVER (PARTITION BY cust_id, session_id ORDER BY time_transition) AS next_page
	     FROM norm_data 
       ) AS t
 WHERE name_page = 'Учебный календарь'
 GROUP BY next_page 
 ORDER BY count_ DESC 

/*Логика:
 *  	В подзапросе t с помощью оконной функции LEAD получаем название страницы, на которую перешел пользователь после страницы 'Учебный календарь'
 *  	В подзапросе t1 сначала достаем данные, у которых текущая страница 'Учебный календарь', потом группируем по следующей странице,
 *  считая количество вхождений.
 * 		В основном запросе сортируем в порядке убывания
 */

DROP TABLE all_data

--3
CREATE TABLE cool_course (
cust_id           INT,
course_id         INT,
data_visit_course TIMESTAMP 
)

INSERT INTO cool_course (cust_id, course_id, data_visit_course)
     VALUES (1, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (3, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (4, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (7, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (8, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (9, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (10, 1, '2022-07-08 17:29:33'::TIMESTAMP),
	        (1, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (3, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (7, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (9, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (10, 1, '2022-07-09 17:29:33'::TIMESTAMP),
	        (1, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (7, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (1, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-11 17:29:33'::TIMESTAMP)

 /*
  * Смотрим на посещаемость. По этому критерию можно судить о "Цепляемости" курса.
  */ 	        
WITH cust_on_web AS (
SELECT  data_visit_course, 
	        course_id, 
	        COUNT(cust_id) AS count_cust_on_web 
	   FROM cool_course 
	  GROUP BY data_visit_course, course_id 
	  ORDER BY data_visit_course
)
SELECT data_visit_course,
       	course_id,
       	(count_cust_on_web::REAL / (SELECT MAX(count_cust_on_web) FILTER(WHERE data_visit_course = '2022-07-08 17:29:33.000'::TIMESTAMP )
       	                              FROM cust_on_web
       	                           )) AS proc_cust_on_web
FROM cust_on_web
  
DROP TABLE cool_course  
 
CREATE TABLE cool_course (
cust_id           INT,
course_id         INT,
data_visit_course TIMESTAMP 
)

INSERT INTO cool_course (cust_id, course_id, data_visit_course)
     VALUES (1, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (3, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (4, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (7, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (8, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (9, 1,  '2022-07-08 17:29:33'::TIMESTAMP),
	        (10, 1, '2022-07-08 17:29:33'::TIMESTAMP),	        
	        (1, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (3, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (4, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (7, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (9, 1,  '2022-07-09 17:29:33'::TIMESTAMP),
	        (10, 1, '2022-07-09 17:29:33'::TIMESTAMP),
	        (11, 1, '2022-07-09 17:29:33'::TIMESTAMP),
	        (12, 1, '2022-07-09 17:29:33'::TIMESTAMP),
	        (13, 1, '2022-07-09 17:29:33'::TIMESTAMP),	        
	        (1, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (3, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (4, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (7, 1,  '2022-07-10 17:29:33'::TIMESTAMP),
	        (10, 1, '2022-07-10 17:29:33'::TIMESTAMP),
	        (11, 1, '2022-07-10 17:29:33'::TIMESTAMP),
	        (12, 1, '2022-07-10 17:29:33'::TIMESTAMP),
	        (13, 1, '2022-07-10 17:29:33'::TIMESTAMP),
	        (14, 1, '2022-07-10 17:29:33'::TIMESTAMP),
	        (15, 1, '2022-07-10 17:29:33'::TIMESTAMP),        
	        (1, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (2, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (3, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (4, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (5, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (6, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (7, 1,  '2022-07-11 17:29:33'::TIMESTAMP),
	        (10, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (11, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (12, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (13, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (14, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (15, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (16, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (17, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (18, 1, '2022-07-11 17:29:33'::TIMESTAMP),
	        (19, 1, '2022-07-11 17:29:33'::TIMESTAMP)

/*
 * Смотрим на прирост новых пользователей на курс. 
 */	   
--EXPLAIN ANALYZE 	        
WITH cust_on_web AS (
SELECT  data_visit_course, 
	        course_id, 
	        COUNT(cust_id) AS count_cust_on_web 
	   FROM cool_course 
	  GROUP BY data_visit_course, course_id 
	  ORDER BY data_visit_course
)
SELECT data_visit_course,
       	course_id,
       	(count_cust_on_web::REAL / (SELECT MAX(count_cust_on_web) FILTER(WHERE data_visit_course = '2022-07-08 17:29:33.000'::TIMESTAMP )
       	                              FROM cust_on_web
       	                           ) - 1) AS proc_new__cust_on_web
FROM cust_on_web

DROP TABLE cool_course  


CREATE TABLE cool_course (
cust_id           INT,
course_id         INT,
advice_to_another INT
)

INSERT INTO cool_course (cust_id, course_id, advice_to_another)
     VALUES (1, 1, 5),
            (2, 1, 10),
            (3, 1, 7),
            (4, 1, 6),
            (5, 1, 4),
            (6, 1, 5),
            (7, 1, 10),
            (8, 1, 9),
            (9, 1, 4),
            (10, 1, 8)

/*
 * Считаем nps и по нему оцениваем курс. 
 */
EXPLAIN ANALYZE -- 129.18
WITH type_cust AS (
SELECT cust_id,
	   course_id,
	   advice_to_another,
	   CASE 
	       WHEN advice_to_another BETWEEN 0 AND 6  THEN 'Критик'
	       WHEN advice_to_another BETWEEN 7 AND 8  THEN 'Нейтрал'
	       WHEN advice_to_another BETWEEN 9 AND 10 THEN 'Адвокат'
	    END AS type_customer
  FROM cool_course 
 ), perc_type_cust AS (
 SELECT perc_type_customer,
 	    type_customer
   FROM ( 
	    SELECT COUNT(cust_id) * 10 AS perc_type_customer,
	          type_customer
	     FROM type_cust 
	    GROUP BY type_customer
	    ORDER BY type_customer
	  ) AS t
), array_type AS (
	  SELECT ARRAY_AGG(perc_type_customer) AS array_perc_type_customer
        FROM perc_type_cust
)
 SELECT array_perc_type_customer[1] - array_perc_type_customer[2] AS NPS
   FROM array_type
 
 DROP TABLE cool_course

 
 --1.1
 /*Метрики:
  * 1)  Процент нерешенных задач, сортировка от макс к мин;
  * 2) 	Процент не приступивших к выполнению.
  */

 CREATE TABLE tasks (
 task_id         INT,
 customer_id     INT,
 solution_result CHAR(25)
 )
 
 --1)
 INSERT INTO tasks (task_id, customer_id, solution_result)
 VALUES (1,  1, 'Верно'         ),
        (1,  2, 'Частично верно'),
        (1,  3, 'Верно'         ),
        (1,  4, 'Неверно'       ),
        (1,  5, 'Неверно'       ),
        (2,  1, 'Верно'         ),
        (2,  2, 'Неверно'       ),
        (2,  3, 'Неверно'       ),
        (2,  4, 'Частично верно'),
        (2,  5, 'Верно'         ),
        (3,  1, 'Неверно'       ),
        (3,  2, 'Частично верно'),
        (3,  3, 'Неверно'       ),
        (3,  4, 'Верно'         ),
        (3,  5, 'Неверно'       ),
        (4,  1, 'Верно'         ),
        (4,  2, 'Неверно'       ),
        (4,  3, 'Частично верно'),
        (4,  4, 'Верно'         ),
        (4,  5, 'Неверно'       ),
        (5,  1, 'Неверно'       ),
        (5,  2, 'Верно'         ),
        (5,  3, 'Частично верно'),
        (5,  4, 'Неверно'       ),
        (5,  5, 'Верно'         ),
        (6,  1, 'Частично верно'),
        (6,  2, 'Неверно'       ),
        (6,  3, 'Верно'         ),
        (6,  4, 'Верно'         ),
        (6,  5, 'Неверно'       ),
        (7,  1, 'Верно'         ),
        (7,  2, 'Верно'         ),
        (7,  3, 'Неверно'       ),
        (7,  4, 'Частично верно'),
        (7,  5, 'Верно'         ),
        (8,  1, 'Неверно'       ),
        (8,  2, 'Частично верно'),
        (8,  3, 'Верно'         ),
        (8,  4, 'Неверно'       ),
        (8,  5, 'Верно'         ),
        (9,  1, 'Частично верно'),
        (9,  2, 'Неверно'       ),
        (9,  3, 'Неверно'       ),
        (9,  4, 'Верно'         ),
        (9,  5, 'Неверно'       ),
        (10, 1, 'Частично верно'),
        (10, 2, 'Верно'         ),
        (10, 3, 'Верно'         ),
        (10, 4, 'Верно'         ),
        (10, 5, 'Верно'         )
 
--EXPLAIN ANALYZE 
 SELECT task_id,
 		count_false_answer::FLOAT / count_respondents * 100 AS procent_false_answ
   FROM (
	   	 SELECT task_id,
		 		COUNT(customer_id) FILTER(WHERE solution_result = 'Неверно') AS count_false_answer,
		 		COUNT(customer_id) AS count_respondents
		   FROM tasks
		  GROUP BY task_id
	    ) AS t
  ORDER BY count_false_answer DESC
  LIMIT 10
  
DROP TABLE tasks

--2)
 CREATE TABLE tasks (
 task_id         INT,
 customer_id     INT,
 solution_result CHAR(25)
 )
 
 
 INSERT INTO tasks (task_id, customer_id, solution_result)
 VALUES (1,  1, 'Верно'         ),
        (1,  2, 'Частично верно'),
        (1,  3,  NULL           ),
        (1,  4, 'Неверно'       ),
        (1,  5, 'Неверно'       ),
        (2,  1,  NULL           ),
        (2,  2, 'Неверно'       ),
        (2,  3, 'Неверно'       ),
        (2,  4,  NULL           ),
        (2,  5, 'Верно'         ),
        (3,  1,  NULL           ),
        (3,  2,  NULL           ),
        (3,  3, 'Неверно'       ),
        (3,  4, 'Верно'         ),
        (3,  5,  NULL           ),
        (4,  1, 'Верно'         ),
        (4,  2, 'Неверно'       ),
        (4,  3, 'Частично верно'),
        (4,  4,  NULL           ),
        (4,  5, 'Неверно'       ),
        (5,  1, 'Неверно'       ),
        (5,  2, 'Верно'         ),
        (5,  3,  NULL           ),
        (5,  4, 'Неверно'       ),
        (5,  5, 'Верно'         ),
        (6,  1, 'Частично верно'),
        (6,  2,  NULL           ),
        (6,  3, 'Верно'         ),
        (6,  4, 'Верно'         ),
        (6,  5,  NULL           ),
        (7,  1, 'Верно'         ),
        (7,  2, 'Верно'         ),
        (7,  3, 'Неверно'       ),
        (7,  4, 'Частично верно'),
        (7,  5, 'Верно'         ),
        (8,  1, 'Неверно'       ),
        (8,  2, 'Частично верно'),
        (8,  3,  NULL           ),
        (8,  4, 'Неверно'       ),
        (8,  5, 'Верно'         ),
        (9,  1, 'Частично верно'),
        (9,  2, 'Неверно'       ),
        (9,  3,  NULL           ),
        (9,  4, 'Верно'         ),
        (9,  5, 'Неверно'       ),
        (10, 1, 'Частично верно'),
        (10, 2, 'Верно'         ),
        (10, 3,  NULL           ),
        (10, 4, 'Верно'         ),
        (10, 5, 'Верно'         )
 
SELECT task_id,
	   not_answ::FLOAT / all_students AS procent_not_answ
  FROM (
		SELECT task_id,
			   COUNT(customer_id) FILTER(WHERE solution_result IS NULL) AS not_answ,
		       COUNT(customer_id) AS all_students
		  FROM tasks 
		 GROUP BY task_id
       ) AS t
 ORDER BY not_answ DESC
 LIMIT 10