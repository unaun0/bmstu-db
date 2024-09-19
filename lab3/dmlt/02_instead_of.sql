-- Триггер INSTEAD OF

DROP VIEW IF EXISTS ProductView;
CREATE VIEW ProductView AS
SELECT
    id,
    name,
    manufacturerID,
    price
FROM
    Product;

CREATE OR REPLACE FUNCTION handle_product_view_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Обработка вставки
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO Product (name, manufacturerID, price, dateCreate, dateChange)
        VALUES (NEW.name, NEW.manufacturerID, NEW.price, CURRENT_DATE, CURRENT_DATE);
        RETURN NEW;
    END IF;
END;
$$;

CREATE TRIGGER product_view_trigger
INSTEAD OF INSERT ON ProductView
FOR EACH ROW
EXECUTE FUNCTION handle_product_view_changes();

INSERT INTO ProductView (name, manufacturerID, price)
VALUES ('A', 1, 19.99);



