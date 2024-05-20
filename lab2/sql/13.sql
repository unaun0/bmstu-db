-- Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3;
-- Получить список продуктов, которые были куплены за последний год, 
-- а также включить количество покупок для каждого продукта и 
-- средний возраст клиентов, которые эти покупки совершили;
SELECT
    p.id,
    p.name,
    purchaseData.totalPurchases,
    purchaseData.avgCustomerAge
FROM
    product p
JOIN (
    SELECT
        pr.productID,
        COUNT(*) AS totalPurchases,
        (
            SELECT
                AVG(EXTRACT(YEAR FROM AGE(c.dateofbirth)))
            FROM
                client c
            WHERE
                c.id IN (
                    SELECT
                        pr2.clientID
                    FROM
                        purchase pr2
                    WHERE
                        pr2.productID = pr.productID
                        AND pr2.dateCreate >= (CURRENT_DATE - INTERVAL '1 year')
                )
        ) AS avgCustomerAge
    FROM
        purchase pr
    WHERE
        pr.dateCreate >= (CURRENT_DATE - INTERVAL '1 year')
    GROUP BY
        pr.productID
) purchaseData ON p.id = purchaseData.productID;
