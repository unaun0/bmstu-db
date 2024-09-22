-- Выполнить загрузку и сохранение JSON файла в таблицу.

DROP TABLE IF EXISTS ManufacturerCopy;
CREATE TABLE ManufacturerCopy(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    URL VARCHAR(255),
    dateCreate DATE,
    dateChange DATE
);

-- chmod uog+w *.json
COPY(
	SELECT row_to_json(m) FROM Manufacturer m
) TO '/Users/tsyar/Desktop/bmstu/bmstu-db/lab5/json/manufacturer.json';

DROP TABLE IF EXISTS importJSON;
CREATE TEMP TABLE importJSON(
    str json
);

COPY importJSON FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/lab5/json/manufacturer.json';


INSERT INTO ManufacturerCopy (id, name, email, URL, dateCreate, dateChange)
SELECT 
    (str->>'id')::int AS id, 
    str->>'name' AS name,
	str->>'email' AS email,
	str->>'URL' AS URL,
	(str->>'dateCreate')::date AS dateCreate,
	(str->>'dateChange')::date AS dateChange
FROM importJSON;

SELECT * FROM ManufacturerCopy;

---
WITH diff AS (
    SELECT
        COALESCE(mc.id, m.id) AS id,
        mc.name AS name1,
        m.name AS name2
    FROM ManufacturerCopy mc
    FULL OUTER JOIN Manufacturer m
    ON mc.id = m.id
    WHERE mc.name IS DISTINCT FROM m.name
)
SELECT COUNT(*) = 0 AS are_identical
FROM diff;








