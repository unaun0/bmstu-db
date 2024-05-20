-- Создание дубликатов строк
WITH Duplicates AS (
    SELECT *
    FROM Purchase
    UNION ALL
    SELECT *
    FROM Purchase
),

-- Удаление дубликатов с использованием ROW_NUMBER()
UniqueRows AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY id, storeID, clientID, productID, productCount, status, dateCreate, dateChange ORDER BY id) AS row_num
    FROM Duplicates
)

SELECT id, storeID, clientID, productID, productCount, status, dateCreate, dateChange
FROM UniqueRows
WHERE row_num = 1;
