-- Многострочная инструкция INSERT, выполняющая вставку в таблицу
-- результирующего набора данных вложенного подзапроса;

DELETE FROM Purchase 
WHERE id > 1000;

INSERT INTO Purchase(
	id,
    storeID,
    clientID,
    productID,
    productCount,
    status,
    dateCreate,
    dateChange
)
SELECT
	1000 + p.id,
    5,                          -- storeID
    1,                          -- clientID
    p.id,                       -- productID
    (
        SELECT MAX(d.count)
        FROM Delivery d
        WHERE d.storeID = 5
    ),                          -- productCount
    'В обработке',              -- status
    CURRENT_DATE,               -- dateCreate
    CURRENT_DATE                -- dateChange
FROM Product p
WHERE p.price < 100;
