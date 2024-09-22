-- CREATE EXTENSION plpython3u;

-- Табличная функция 

CREATE OR REPLACE FUNCTION purchases_from_status(status varchar)
RETURNS TABLE (id int, clientID int, productID int) AS
$$
	prepared_query = plpy.prepare("SELECT id, clientID, productID FROM Purchase WHERE Status LIKE $1", ["varchar"])
	result_query = plpy.execute(prepared_query, [status])
	result_table = list()
	for str in result_query:
		result_table.append(str)
	return result_query
$$ LANGUAGE plpython3u;

SELECT * FROM purchases_from_status('Отменен');