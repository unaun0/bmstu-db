-- CREATE EXTENSION plpython3u;

-- Хранимая процедура

CREATE OR REPLACE PROCEDURE update_product_count(id int, count int) AS
$$
	plpy.execute(
		plpy.prepare(
			"UPDATE Purchase SET ProductCount = $2 WHERE id = $1", ["int", "int"]
		), 
		[id, count]
	)
$$ LANGUAGE plpython3u;

CALL update_product_count(6, 100);

SELECT * FROM Purchase
WHERE id = 6;
