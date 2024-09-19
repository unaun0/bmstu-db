-- CREATE EXTENSION plpython3u;

-- Триггер

CREATE OR REPLACE FUNCTION update_trigger()
RETURNS TRIGGER AS
$$
	plpy.notice("Что-то изменилось в заказе")
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER upd
AFTER UPDATE ON Purchase
FOR EACH ROW
EXECUTE FUNCTION update_trigger();

UPDATE Purchase SET ProductCount = 1 WHERE id = 1;
