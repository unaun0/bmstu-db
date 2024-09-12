-- Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING;

SELECT
    productID,
    COUNT(*) AS totalPurchases
FROM
    purchase
GROUP BY
	productID
ORDER BY 
	productID;
