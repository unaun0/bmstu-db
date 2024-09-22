-- Рекурсивная функция

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

CREATE OR REPLACE FUNCTION get_all_product_analogs(product_id INT)
RETURNS TABLE (id INT, name VARCHAR) AS $$
WITH RECURSIVE analogs_cte(id, name) AS (
    -- Базовый запрос: находим все аналоги начального продукта
    SELECT p.id, p.name
    FROM Product p
    JOIN ProductAnalog pa ON pa.analogProductID = p.id
    WHERE pa.productID = product_id

    UNION

    -- Рекурсивный запрос: продолжаем искать аналоги для найденных аналогов
    SELECT p.id, p.name
    FROM Product p
    JOIN ProductAnalog pa ON pa.analogProductID = p.id
    JOIN analogs_cte a ON a.id = pa.productID
)
SELECT * FROM analogs_cte;
$$ LANGUAGE SQL;

select * from get_all_product_analogs(1);


