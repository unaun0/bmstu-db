-- Обобщенное табличное выражение для получения данных о продуктах
WITH ProductInfo AS (
    SELECT
        p.id AS productID,
        p.name AS productName,
        c.name AS categoryName,
        m.name AS manufacturerName
    FROM
        Product p
    JOIN
        Category c ON p.categoryID = c.id
    JOIN
        Manufacturer m ON p.manufacturerID = m.id
)

-- Основной запрос, использующий CTE
SELECT
    productID,
    productName,
    categoryName,
    manufacturerName
FROM
    ProductInfo
ORDER BY
    productName;