-- Защита

WITH MostOrderedProduct AS (
    SELECT
        EXTRACT(YEAR FROM c.dateOfBirth) AS birth_year,
        p.name AS product_name,
        COUNT(*) AS order_count
    FROM Purchase pu
    JOIN Client c ON pu.clientID = c.id
    JOIN Product p ON pu.productID = p.id
    GROUP BY birth_year, p.name
),	
TopProductPerYear AS (
    SELECT
        birth_year,
        product_name,
        order_count,
        ROW_NUMBER() OVER (PARTITION BY birth_year ORDER BY order_count DESC) AS rn
    FROM MostOrderedProduct
)
SELECT 
    birth_year, 
    product_name 
FROM TopProductPerYear
WHERE rn = 1;


