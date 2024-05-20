-- Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING;
-- Получить общее количество заказов для каждого товара;
SELECT
    productID,
    COUNT(*) AS totalPurchases
FROM
    purchase
GROUP BY
    productID
ORDER BY 
	productID;
