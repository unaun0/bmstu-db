-- Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM;
-- Получить список купленных товаров с количеством покупок для каждого продукта;
SELECT
    p.id,
    p.name,
    p.manufacturerID,
    purchases.totalPurchases
FROM
    product p
JOIN (
    SELECT
        pr.productID,
        COUNT(*) AS totalPurchases
    FROM
        purchase pr
    WHERE
        pr.status = 'Выполнен'
    GROUP BY
        pr.productID
) purchases ON p.id = purchases.productID;