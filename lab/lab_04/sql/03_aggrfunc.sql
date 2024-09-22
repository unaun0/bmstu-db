-- CREATE EXTENSION plpython3u;

-- Агрегатная функция

CREATE OR REPLACE FUNCTION count_by_status(status varchar)
RETURNS int AS
$$
	prepared_query = plpy.prepare("SELECT 1 FROM Purchase WHERE Status LIKE $1", ["varchar"])
	result_query = plpy.execute(prepared_query, [status])
	return len(result_query)
$$ LANGUAGE plpython3u;

SELECT * FROM count_by_status('Отменен');
