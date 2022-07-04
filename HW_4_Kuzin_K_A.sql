/*�������� �����

������� 1. ������������� ���� ������, ���������� ��� �����������:
	� ���� (����������, ����������� � �. �.);
	� ���������� (�������, ���������� � �. �.);
	� ������ (������, �������� � �. �.).
��� ������� �� �������: ����-���������� � ����������-������, ��������� ������ �� ������. ������ ������� �� ������� � film_actor.
���������� � ��������-������������:
	� ������� ����������� ��������� ������.
	� �������������� �������� ������ ������������� ���������������;
	� ������������ ��������� �� ������ ��������� null-��������, �� ������ ����������� ��������� � ��������� ���������.
���������� � �������� �� �������:
	� ������� ����������� ��������� � ������� ������.

� �������� ������ �� ������� �������� ������� �������� ������ � ������� �� ���������� � ������ ������� �� 5 ����� � �������.

�������������� �����

������� 1. �������� ����� ������� film_new �� ���������� ������:
	� film_name � �������� ������ � ��� ������ varchar(255) � ����������� not null;
	� film_year � ��� ������� ������ � ��� ������ integer, �������, ��� �������� ������ ���� ������ 0;
	� film_rental_rate � ��������� ������ ������ � ��� ������ numeric(4,2), �������� �� ��������� 0.99;
	� film_duration � ������������ ������ � ������� � ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0.
���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

������� 2. ��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
	� film_name � array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler�s List];
	� film_year � array[1994, 1999, 1985, 1994, 1993];
	� film_rental_rate � array[2.99, 0.99, 1.99, 2.99, 3.99];
	� film_duration � array[142, 189, 116, 142, 195].

������� 3. �������� ��������� ������ ������� � ������� film_new � ������ ����������, ��� ��������� ������ ���� ������� ��������� �� 1.41.

������� 4. ����� � ��������� Back to the Future ��� ���� � ������, ������� ������ � ���� ������� �� ������� film_new.

������� 5. �������� � ������� film_new ������ � ����� ������ ����� ������.

������� 6. �������� SQL-������, ������� ������� ��� ������� �� ������� film_new, � ����� ����� ����������� �������
������������� ������ � ������, ���������� �� �������.

������� 7. ������� ������� film_new.
 */

CREATE TABLE "language"(
	language_id   SERIAL       PRIMARY KEY,
	language_name VARCHAR(100) NOT NULL UNIQUE,
	create_at     TIMESTAMP    DEFAULT NOW(),
	last_update   TIMESTAMP,  
	deleted       BOOLEAN      NOT NULL DEFAULT FALSE
);

DROP TABLE "language";

CREATE TABLE nationality(
	nationality_id   SERIAL       PRIMARY KEY,
	nationality_name VARCHAR(100) NOT NULL UNIQUE,
	create_at        TIMESTAMP    DEFAULT NOW(),
	last_update      TIMESTAMP,
	deleted          BOOLEAN      NOT NULL DEFAULT FALSE
);

DROP TABLE nationality;

CREATE TABLE country(
	country_id   SERIAL       PRIMARY KEY,
	country_name VARCHAR(100) NOT NULL UNIQUE,
	create_at    TIMESTAMP    DEFAULT NOW(),
	last_update  TIMESTAMP,
	deleted      BOOLEAN      NOT NULL DEFAULT FALSE
);

DROP TABLE country;

CREATE TABLE language_nationality (
    PRIMARY KEY(language_id,nationality_id),
	language_id    INT2 NOT NULL REFERENCES "language"(language_id),
	nationality_id INT2 NOT NULL REFERENCES nationality(nationality_id)
);

DROP TABLE language_nationality;

CREATE TABLE nationality_country(
	PRIMARY KEY(nationality_id, country_id),
	nationality_id INT2 NOT NULL REFERENCES nationality(nationality_id),
	country_id     INT2 NOT NULL REFERENCES country(country_id)
);

DROP TABLE nationality_country;

INSERT INTO "language" (language_name)
     VALUES ('English'), ('French'), ('Russian'), ('Japanese'), ('Chinese');

INSERT INTO nationality (nationality_name)
     VALUES ('Slavs'), ('Anglo_Saxons'), ('Azerbaijanis'), ('Georgians'), ('Japanese');

INSERT INTO country (country_name)
     VALUES ('Russia'), ('Germany'), ('Azerbaijan'), ('Georgia'), ('Japan');

INSERT INTO language_nationality (language_id, nationality_id)
     VALUES (1, 2), (1, 1), (2, 3), (4, 2), (3, 1);

INSERT INTO nationality_country (nationality_id, country_id)
     VALUES (1, 1), (2, 2), (1, 3), (5,5), (3, 1);

--���

CREATE TABLE Kuzin_K_A_film_new(
	film_id          SERIAL       PRIMARY KEY,	
	film_name        VARCHAR(255) NOT NULL,
	film_year        INTEGER      
	                 CHECK(film_year > 0),
	film_rental_rate NUMERIC(4,2) DEFAULT  0.99,
	film_duration    INTEGER      NOT NULL 
	                 CHECK(film_duration > 0)
);
	                
INSERT INTO Kuzin_K_A_film_new (film_name, film_year, film_rental_rate, film_duration) 
     SELECT UNNEST(ARRAY['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler�s List']),
            UNNEST(ARRAY[1994, 1999, 1985, 1994, 1993]),
            UNNEST(ARRAY[2.99, 0.99, 1.99, 2.99, 3.99]),
            UNNEST(ARRAY[142, 189, 116, 142, 195]);
     
UPDATE Kuzin_K_A_film_new
   SET film_rental_rate = film_rental_rate + 1.41;

DELETE FROM Kuzin_K_A_film_new
      WHERE film_name = 'Back to the Future';
      
INSERT INTO Kuzin_K_A_film_new (film_name, film_year, film_rental_rate, film_duration) 
     VALUES ('New film',1964, 1.28, 118);

SELECT *,  (film_duration/60.0):: NUMERIC(4, 1) AS "film_duration_in_hours"
  FROM Kuzin_K_A_film_new;
  
DROP TABLE Kuzin_K_A_film_new;
  
