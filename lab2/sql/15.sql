-- Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY и предложения HAVING;
-- Получить список id товаров, у которых общее количество заказов 
-- для каждого товара больше 3;
SELECT
    productID,
    COUNT(*) AS totalPurchases
FROM
    purchase
GROUP BY
    productID
HAVING
    COUNT(*) > 3;