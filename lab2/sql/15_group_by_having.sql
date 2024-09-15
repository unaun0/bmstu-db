-- Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY и предложения HAVING;

SELECT
    productID,
    COUNT(*) AS totalPurchases
FROM
    purchase
GROUP BY
    productID
HAVING
    COUNT(*) > 3
ORDER BY productID;