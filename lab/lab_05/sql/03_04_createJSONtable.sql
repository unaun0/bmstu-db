-- Создать таблицу, в которой будет атрибут(-ы) с типом JSON.

DROP TABLE IF EXISTS just_table;
CREATE TABLE just_table(
	id SERIAL PRIMARY KEY,
	manufacturerID INT,
	FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(id) ON DELETE SET NULL,
	INFO JSON
);

INSERT INTO just_table(id, manufacturerID, INFO) VALUES
	(1, 3, '{"country": "England", "year": "1995"}'),
	(2, 1, '{"country": "USA", "year": "2005"}'),
	(3, 102, '{"country": "Russia", "year": "1975"}');

SELECT * FROM just_table;

-- Извлечь JSON фрагмент из JSON документа

SELECT INFO
FROM just_table
WHERE id = 1;

-- Извлечь значения конкретных узлов или атрибутов JSON документа

SELECT INFO->>'country' as INFO
FROM just_table
WHERE id = 1;

-- Выполнить проверку существования узла или атрибута JSON

SELECT * FROM just_table
where json_extract_path(INFO, 'year') IS NOT NULL;


-- Изменить JSON документ

UPDATE just_table
SET INFO = INFO::JSONB || '{"year": "2000"}'::JSONB
WHERE ID = 1;

SELECT * FROM just_table;

-- Разделить JSON документ на несколько строк по узлам

SELECT 
	json_extract_path(INFO, 'country') i,
	json_extract_path(INFO, 'year') y
FROM just_table;

             








