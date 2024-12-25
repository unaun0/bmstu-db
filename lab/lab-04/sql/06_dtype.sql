-- CREATE EXTENSION plpython3u;

-- Тип данных

DROP FUNCTION purchase_base_info;
DROP TYPE purchase_base_info;

CREATE TYPE purchase_base_info AS(
	id int,
	clientID int,
	status VARCHAR
);

CREATE OR REPLACE FUNCTION purchase_base_info(id int)
RETURNS purchase_base_info AS
$$
	result = plpy.execute(
		plpy.prepare(
			"SELECT id, clientID, status FROM Purchase WHERE id = $1", 
            ["int"]
        ), 
		[id]
    )
	if len(result) != 0:
		row = result[0]
		return (row["id"], row["clientid"], row["status"])
$$ LANGUAGE plpython3u;

SELECT * FROM purchase_base_info(10);


