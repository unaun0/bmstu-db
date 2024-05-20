DROP TABLE IF EXISTS Table1;
-- Создание таблицы Table1
CREATE TABLE Table1 (
    id SERIAL PRIMARY KEY,
    var1 VARCHAR(255),
    valid_from_dttm DATE,
    valid_to_dttm DATE
);

DROP TABLE IF EXISTS Table2;
-- Создание таблицы Table2
CREATE TABLE Table2 (
    id SERIAL PRIMARY KEY,
    var2 VARCHAR(255),
    valid_from_dttm DATE,
    valid_to_dttm DATE
);

-- Заполнение таблицы Table1 данными
INSERT INTO Table1 (var1, valid_from_dttm, valid_to_dttm) VALUES
    ('A', '2018-09-01', '2018-09-15'),
    ('B', '2018-09-16', '5999-12-31');

-- Заполнение таблицы Table2 данными
INSERT INTO Table2 (var2, valid_from_dttm, valid_to_dttm) VALUES
    ('A', '2018-09-01', '2018-09-18'),
    ('B', '2018-09-19', '5999-12-31');

-- Версионное соединение таблиц Table1 и Table2
SELECT 
    t1.id,
    t1.var1,
    t2.var2,
    CASE
        WHEN t1.valid_from_dttm <= t2.valid_from_dttm AND t1.valid_to_dttm >= t2.valid_to_dttm THEN t2.valid_from_dttm
        WHEN t1.valid_from_dttm >= t2.valid_from_dttm AND t1.valid_to_dttm <= t2.valid_to_dttm THEN t1.valid_from_dttm
        WHEN t1.valid_from_dttm <= t2.valid_from_dttm AND t1.valid_to_dttm >= t2.valid_from_dttm THEN t2.valid_from_dttm
        WHEN t1.valid_from_dttm >= t2.valid_from_dttm AND t1.valid_from_dttm <= t2.valid_to_dttm THEN t1.valid_from_dttm
    END AS valid_from_dttm,
    CASE
        WHEN t1.valid_to_dttm >= t2.valid_to_dttm AND t1.valid_from_dttm <= t2.valid_from_dttm THEN t2.valid_to_dttm
        WHEN t1.valid_to_dttm <= t2.valid_to_dttm AND t1.valid_from_dttm >= t2.valid_from_dttm THEN t1.valid_to_dttm
        WHEN t1.valid_to_dttm >= t2.valid_from_dttm AND t1.valid_to_dttm <= t2.valid_to_dttm THEN t1.valid_to_dttm
        WHEN t1.valid_to_dttm <= t2.valid_to_dttm AND t1.valid_from_dttm >= t2.valid_from_dttm THEN t2.valid_to_dttm
    END AS valid_to_dttm
FROM 
    Table1 t1
JOIN 
    Table2 t2 ON t1.id = t2.id
        AND (t1.valid_from_dttm <= t2.valid_to_dttm AND t1.valid_to_dttm >= t2.valid_from_dttm);

