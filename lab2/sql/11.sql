-- Создание новой временной локальной таблицы из результирующего набора
-- данных инструкции SELECT;

DROP TABLE IF EXISTS Selling;

SELECT
    p.id,
    p.name,
    p.manufacturerID,
	p.price,
    (
        SELECT SUM(purchase.productCount)
        FROM purchase
        WHERE purchase.productID = p.id AND purchase.status = 'Выполнен'
    ) AS productSoldCount
INTO Selling
FROM product p;

SELECT * 
FROM Selling 
WHERE productSoldCount > 0;
