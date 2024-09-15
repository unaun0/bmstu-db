-- Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ

DROP TABLE IF EXISTS ProductAnalog;
CREATE TABLE ProductAnalog (
    productID INT,
    analogProductID INT,
    PRIMARY KEY (productID, analogProductID),
    FOREIGN KEY (productID) REFERENCES Product(id),
    FOREIGN KEY (analogProductID) REFERENCES Product(id)
);

INSERT INTO ProductAnalog (productID, analogProductID) VALUES
    (1, 2),
    (2, 3),
    (3, 4),
	(1, 5);

CREATE OR REPLACE PROCEDURE find_all_analog_products(start_product_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    record RECORD;
BEGIN
    -- Выводим сообщение о начале процедуры
    RAISE NOTICE 'Аналоги продукта с ID %:', start_product_id;

    -- Выполняем рекурсивный запрос для поиска всех аналогов
    FOR record IN
        WITH RECURSIVE AnalogHierarchy AS (
            -- Базовый случай: выбираем начальный продукт
            SELECT
                productID,
                analogProductID
            FROM
                ProductAnalog
            WHERE
                productID = start_product_id
        
            UNION ALL
        
            -- Рекурсивная часть: находим аналоговые продукты для текущих аналогов
            SELECT
                pa.productID,
                pa.analogProductID
            FROM
                ProductAnalog pa
            INNER JOIN
                AnalogHierarchy ah ON pa.productID = ah.analogProductID
        )
        SELECT
            productID,
            analogProductID
        FROM
            AnalogHierarchy
    LOOP
        -- Выводим информацию о каждом найденном аналоге
        RAISE NOTICE 'Продукт ID: %, Аналоговый продукт ID: %',
            record.productID,
            record.analogProductID;
    END LOOP;
END;
$$;

CALL find_all_analog_products(1);
DROP TABLE IF EXISTS ProductAnalog;
