-- Триггер AFTER

DROP TABLE IF EXISTS ProductChangeLog;
CREATE TABLE ProductChangeLog (
    id SERIAL PRIMARY KEY,
    productID INT,
    action VARCHAR(10), -- 'INSERT' или 'UPDATE'
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_product_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Вставляем запись о изменении в таблицу логов
    INSERT INTO ProductChangeLog (productID, action)
    VALUES (NEW.id, TG_OP);

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER product_changes_trigger
AFTER INSERT OR UPDATE ON Product
FOR EACH ROW
EXECUTE FUNCTION log_product_changes();

UPDATE Product SET price = 120.00 WHERE id = 1;

SELECT * FROM ProductChangeLog;

-- DROP TABLE IF EXISTS ProductChangeLog;

