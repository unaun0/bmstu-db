-- Обобщенное табличное выражение для получения данных о продуктах
WITH ProductInfo AS (
    SELECT
        p.id AS productID,
        p.name AS productName,
        m.name AS manufacturerName
    FROM
        Product p
    JOIN
        Manufacturer m ON p.manufacturerID = m.id
)

-- Основной запрос, использующий CTE
SELECT
    productID,
    productName,
    manufacturerName
FROM
    ProductInfo
ORDER BY
    productName;