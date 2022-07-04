/*
 * Задание 1
	1.1 Сгруппировать по месяцам количество заявок, сумму выдач, вычислить долю выдач.
	1.2 Для каждого месяца указать сумму выдач за предыдущий месяц, посчитать % изменения суммы выдач
	текущего месяца к предыдущему.

	Задание 2 Добавить индикатор, который будет выделять следующие значения:
	*   Если сумма по заявке больше 2000000 и дата создания заявки «март 2020» - 1
	*	Если сумма по заявке больше 1000000, но меньше 2000000 и дата создания заявки «март 2020» - 2
	*	Все остальные заявки не должны попасть в результат выполнения запроса.

	Задание 3 Показать источник, через который пришло наибольшее число заявок
 */


CREATE TABLE TEST_SQL (
ST_ORD               VARCHAR(50),
TYPE_PRODUCT_NAME    VARCHAR(50),
PRODUCT_INFOSOURCE1  VARCHAR(10),
CREATE_DATE          DATE,
INDEX_LEAD           INT,
INDEX_ISSUE          INT,
INDEX_SUM            REAL
)

INSERT INTO TEST_SQL(ST_ORD,TYPE_PRODUCT_NAME, PRODUCT_INFOSOURCE1, CREATE_DATE,INDEX_LEAD, INDEX_ISSUE,INDEX_SUM)
VALUES ('Согласие',                'Обычная заявка',          'source1', '2017-11-30', 1, 1, 1600000),
       ('Согласие',                'Обычная заявка',          'source2', '2018-02-05', 1, 1, 2376000),
       ('Согласие',                'Обычная заявка',          'source5', '2017-12-27', 1, 1, 4860000),
       ('Согласие',                'Обычная заявка',          'source6', '2018-03-07', 1, 1, 1500000),
       ('Не подходит по критериям','Обычная заявка',          'source6', '2018-03-29', 1, 1, 3500000),
       ('Согласие',                'Заявка не для обработки', 'source4', '2018-06-26', 1, 1, 1800000),
       ('Согласие',                'Заявка не для обработки', 'source3', '2018-06-06', 1, 1, 3200000),
       (NULL,                      'Заявка не для обработки', 'source3', '2018-06-21', 1, 1, 3375900),
       ('Согласие',                'Заявка не для обработки', 'source3', '2018-06-19', 1, 1, 1700000),
       ('Согласие',                'Обычная заявка',          'source5', '2018-07-26', 1, 1, 1288000),
       ('Согласие',                'Обычная заявка',          'source5', '2018-07-23', 1, 1, 1275400),
       ('Согласие',                'Обычная заявка',          'source5', '2018-07-31', 1, 1, 1600000),
       ('Не подходит по критериям','Обычная заявка',          'source5', '2018-09-30', 1, 1, 1764000),
       ('Согласие',                'Обычная заявка',          'source5', '2018-08-03', 1, 1, 4000000),
       ('Согласие',                'Обычная заявка',          'source5', '2018-07-26', 1, 1, 1450000),
       ('Отказ',                   'Обычная заявка',          'source5', '2018-09-06', 1, 1, 2363960.71),
       ('Согласие',                'Обычная заявка',          'source5', '2018-08-27', 1, 1, 2486939),
       ('Согласие',                'Обычная заявка',          'source5', '2018-08-28', 1, 1, 2576693.63),
       ('Согласие',                'Обычная заявка',          'source5', '2018-10-08', 1, 1, 1604125),
       ('Согласие',                'Обычная заявка',          'source5', '2018-07-30', 1, 1, 940000),
       ('Согласие',                'Заявка не для обработки', 'source4', '2018-07-09', 1, 1, 5000000)
 
--Задания 1 и 2
--EXPLAIN ANALYZE 
WITH NORMAL_DATA AS (
	SELECT ST_ORD,
	       TYPE_PRODUCT_NAME, 
	       PRODUCT_INFOSOURCE1, 
	       CREATE_DATE,
	       INDEX_LEAD, 
	       INDEX_ISSUE,
	       INDEX_SUM
	  FROM TEST_SQL 
	 WHERE PRODUCT_INFOSOURCE1 IS NOT NULL
	   AND CREATE_DATE         IS NOT NULL
	   AND INDEX_LEAD          IS NOT NULL
	   AND INDEX_ISSUE         IS NOT NULL
	   AND INDEX_SUM           IS NOT NULL
	   AND ST_ORD = 'Согласие'	   
	   AND TYPE_PRODUCT_NAME = 'Обычная заявка'
), FIRST_PART AS (
	SELECT   DATE_TRUNC('MONTH', CREATE_DATE) AS "MONTH",
	         COUNT(INDEX_LEAD) FILTER(WHERE INDEX_LEAD  = 1) AS COUNT_REQUEST_BY_MONTH,
	         SUM(INDEX_SUM)    FILTER(WHERE INDEX_ISSUE = 1) AS SUM_DISBURSEMENTS_BY_MONTH,
	         SUM(INDEX_SUM)    FILTER(WHERE INDEX_ISSUE = 1) / (SELECT SUM(INDEX_SUM) FILTER(WHERE INDEX_ISSUE = 1) 
	                                                              FROM NORMAL_DATA) AS SHARE_OF_DISBURSEMENTS_BY_MONTH
	    FROM NORMAL_DATA 
	   WHERE ST_ORD = 'Согласие'
	     AND TYPE_PRODUCT_NAME != 'Заявка не для обработки'
	   GROUP BY DATE_TRUNC('MONTH', CREATE_DATE)
)
SELECT "MONTH",
       COUNT_REQUEST_BY_MONTH,
       SUM_DISBURSEMENTS_BY_MONTH,
       SHARE_OF_DISBURSEMENTS_BY_MONTH,
       PREVIOUS_SUM,
       PROC_NOW_SUM_DEV_PREV_SUM,
       IND
  FROM (
	SELECT "MONTH",
	       COUNT_REQUEST_BY_MONTH,
	       SUM_DISBURSEMENTS_BY_MONTH,
	       SHARE_OF_DISBURSEMENTS_BY_MONTH,
	       LAG(SUM_DISBURSEMENTS_BY_MONTH) OVER (ORDER BY "MONTH") AS PREVIOUS_SUM,
	       ROUND((SUM_DISBURSEMENTS_BY_MONTH * 100 / (LAG(SUM_DISBURSEMENTS_BY_MONTH) OVER (ORDER BY "MONTH"))) ::NUMERIC, 2) AS PROC_NOW_SUM_DEV_PREV_SUM,
	       CASE 
	       		WHEN  SUM_DISBURSEMENTS_BY_MONTH > 2000000 AND "MONTH" = '2020-03-01'                     THEN 1
	       		WHEN  (SUM_DISBURSEMENTS_BY_MONTH BETWEEN 1000000 AND 2000000) AND "MONTH" = '2020-03-01' THEN 2
	       		ELSE 0
	       END AS IND
	  FROM FIRST_PART
        ) AS T
  WHERE IND != 0  
/*ЛОГИКА:
 * 		Задание 1
 *     В CTE NORMAL_DATA чистим данные и отбираем только нужные.
 *     В CTE FIRST_PART группируем данные по месяцам и считаем количество заявок, сумму выдач и долю выдач на месяц. 
 * Используем filter для того, чтобы посмотреть только те заявки/выдачи, которые есть в системе.
 *     В основном запросе используется оконная функция (с сортировкой по месяцам) и функция lag для того, чтобы получить 
 * сумму выдач за предыдущий месяц. Кроме того, считается процентное изменение суммы выдач текущего месяца по отношению к предыдущему.
 *       Задание 2
 *     В основном запросе задания 1 добавил оператор case, чтобы разобрать на случаи, указанные в ТЗ.
 * 	   Завернул основной запрос задания 1 в подзапрос и фильтрую по условию  IND != 0, так как эти строки нас не интересуют.
 */
  
 --Задание 3
--EXPLAIN ANALYZE 
WITH NORMAL_DATA AS (
	SELECT  ST_ORD,
	        TYPE_PRODUCT_NAME, 
	        PRODUCT_INFOSOURCE1, 
	        CREATE_DATE,
	        INDEX_LEAD, 
	        INDEX_ISSUE,
	        INDEX_SUM
	  FROM TEST_SQL 
	 WHERE PRODUCT_INFOSOURCE1 IS NOT NULL
	   AND CREATE_DATE         IS NOT NULL
	   AND INDEX_LEAD          IS NOT NULL
	   AND INDEX_ISSUE         IS NOT NULL
	   AND INDEX_SUM           IS NOT NULL
	   AND ST_ORD = 'Согласие'	   
	   AND TYPE_PRODUCT_NAME = 'Обычная заявка'
), COUNT_SOURCE_TABLE AS (
        SELECT PRODUCT_INFOSOURCE1,
		       COUNT(PRODUCT_INFOSOURCE1) AS COUNT_SOURCE
		  FROM NORMAL_DATA
		 GROUP BY PRODUCT_INFOSOURCE1
)
SELECT PRODUCT_INFOSOURCE1,
	   COUNT_SOURCE
  FROM COUNT_SOURCE_TABLE AS CST
 WHERE COUNT_SOURCE = (
						SELECT MAX(COUNT_SOURCE)
						  FROM COUNT_SOURCE_TABLE
					  )
/*ЛОГИКА:
 *    В CTE NORMAL_DATA выбираем нужные данные.
 *    В CTE COUNT_SOURCE_TABLE делаем запрос к NORMAL_DATA, группируем данные по PRODUCT_INFOSOURCE1 и 
 * считаем сколько заявок пришло через каждый источник
 *    В основном запросе из COUNT_SOURCE_TABLE берем только те значения, которые равны максимальному COUNT_SOURCE 
 */