/*
 * ������� 1
	1.1 ������������� �� ������� ���������� ������, ����� �����, ��������� ���� �����.
	1.2 ��� ������� ������ ������� ����� ����� �� ���������� �����, ��������� % ��������� ����� �����
	�������� ������ � �����������.

	������� 2 �������� ���������, ������� ����� �������� ��������� ��������:
	*   ���� ����� �� ������ ������ 2000000 � ���� �������� ������ ����� 2020� - 1
	*	���� ����� �� ������ ������ 1000000, �� ������ 2000000 � ���� �������� ������ ����� 2020� - 2
	*	��� ��������� ������ �� ������ ������� � ��������� ���������� �������.

	������� 3 �������� ��������, ����� ������� ������ ���������� ����� ������
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
VALUES ('��������',                '������� ������',          'source1', '2017-11-30', 1, 1, 1600000),
       ('��������',                '������� ������',          'source2', '2018-02-05', 1, 1, 2376000),
       ('��������',                '������� ������',          'source5', '2017-12-27', 1, 1, 4860000),
       ('��������',                '������� ������',          'source6', '2018-03-07', 1, 1, 1500000),
       ('�� �������� �� ���������','������� ������',          'source6', '2018-03-29', 1, 1, 3500000),
       ('��������',                '������ �� ��� ���������', 'source4', '2018-06-26', 1, 1, 1800000),
       ('��������',                '������ �� ��� ���������', 'source3', '2018-06-06', 1, 1, 3200000),
       (NULL,                      '������ �� ��� ���������', 'source3', '2018-06-21', 1, 1, 3375900),
       ('��������',                '������ �� ��� ���������', 'source3', '2018-06-19', 1, 1, 1700000),
       ('��������',                '������� ������',          'source5', '2018-07-26', 1, 1, 1288000),
       ('��������',                '������� ������',          'source5', '2018-07-23', 1, 1, 1275400),
       ('��������',                '������� ������',          'source5', '2018-07-31', 1, 1, 1600000),
       ('�� �������� �� ���������','������� ������',          'source5', '2018-09-30', 1, 1, 1764000),
       ('��������',                '������� ������',          'source5', '2018-08-03', 1, 1, 4000000),
       ('��������',                '������� ������',          'source5', '2018-07-26', 1, 1, 1450000),
       ('�����',                   '������� ������',          'source5', '2018-09-06', 1, 1, 2363960.71),
       ('��������',                '������� ������',          'source5', '2018-08-27', 1, 1, 2486939),
       ('��������',                '������� ������',          'source5', '2018-08-28', 1, 1, 2576693.63),
       ('��������',                '������� ������',          'source5', '2018-10-08', 1, 1, 1604125),
       ('��������',                '������� ������',          'source5', '2018-07-30', 1, 1, 940000),
       ('��������',                '������ �� ��� ���������', 'source4', '2018-07-09', 1, 1, 5000000)
 
--������� 1 � 2
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
	   AND ST_ORD = '��������'	   
	   AND TYPE_PRODUCT_NAME = '������� ������'
), FIRST_PART AS (
	SELECT   DATE_TRUNC('MONTH', CREATE_DATE) AS "MONTH",
	         COUNT(INDEX_LEAD) FILTER(WHERE INDEX_LEAD  = 1) AS COUNT_REQUEST_BY_MONTH,
	         SUM(INDEX_SUM)    FILTER(WHERE INDEX_ISSUE = 1) AS SUM_DISBURSEMENTS_BY_MONTH,
	         SUM(INDEX_SUM)    FILTER(WHERE INDEX_ISSUE = 1) / (SELECT SUM(INDEX_SUM) FILTER(WHERE INDEX_ISSUE = 1) 
	                                                              FROM NORMAL_DATA) AS SHARE_OF_DISBURSEMENTS_BY_MONTH
	    FROM NORMAL_DATA 
	   WHERE ST_ORD = '��������'
	     AND TYPE_PRODUCT_NAME != '������ �� ��� ���������'
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
/*������:
 * 		������� 1
 *     � CTE NORMAL_DATA ������ ������ � �������� ������ ������.
 *     � CTE FIRST_PART ���������� ������ �� ������� � ������� ���������� ������, ����� ����� � ���� ����� �� �����. 
 * ���������� filter ��� ����, ����� ���������� ������ �� ������/������, ������� ���� � �������.
 *     � �������� ������� ������������ ������� ������� (� ����������� �� �������) � ������� lag ��� ����, ����� �������� 
 * ����� ����� �� ���������� �����. ����� ����, ��������� ���������� ��������� ����� ����� �������� ������ �� ��������� � �����������.
 *       ������� 2
 *     � �������� ������� ������� 1 ������� �������� case, ����� ��������� �� ������, ��������� � ��.
 * 	   �������� �������� ������ ������� 1 � ��������� � �������� �� �������  IND != 0, ��� ��� ��� ������ ��� �� ����������.
 */
  
 --������� 3
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
	   AND ST_ORD = '��������'	   
	   AND TYPE_PRODUCT_NAME = '������� ������'
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
/*������:
 *    � CTE NORMAL_DATA �������� ������ ������.
 *    � CTE COUNT_SOURCE_TABLE ������ ������ � NORMAL_DATA, ���������� ������ �� PRODUCT_INFOSOURCE1 � 
 * ������� ������� ������ ������ ����� ������ ��������
 *    � �������� ������� �� COUNT_SOURCE_TABLE ����� ������ �� ��������, ������� ����� ������������� COUNT_SOURCE 
 */