/*Основная часть

Задание 1. Спроектируйте базу данных, содержащую три справочника:
	· язык (английский, французский и т. п.);
	· народность (славяне, англосаксы и т. п.);
	· страны (Россия, Германия и т. п.).
Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
Требования к таблицам-справочникам:
	· наличие ограничений первичных ключей.
	· идентификатору сущности должен присваиваться автоинкрементом;
	· наименования сущностей не должны содержать null-значения, не должны допускаться дубликаты в названиях сущностей.
Требования к таблицам со связями:
	· наличие ограничений первичных и внешних ключей.

В качестве ответа на задание пришлите запросы создания таблиц и запросы по добавлению в каждую таблицу по 5 строк с данными.

Дополнительная часть

Задание 1. Создайте новую таблицу film_new со следующими полями:
	· film_name — название фильма — тип данных varchar(255) и ограничение not null;
	· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;
	· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;
	· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, что значение должно быть больше 0.
Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
	· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler’s List];
	· film_year — array[1994, 1999, 1985, 1994, 1993];
	· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];
	· film_duration — array[142, 189, 116, 142, 195].

Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, что стоимость аренды всех фильмов поднялась на 1.41.

Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом из таблицы film_new.

Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.

Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую вычисляемую колонку
«длительность фильма в часах», округлённую до десятых.

Задание 7. Удалите таблицу film_new.
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

--Доп

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
     SELECT UNNEST(ARRAY['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List']),
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
  
