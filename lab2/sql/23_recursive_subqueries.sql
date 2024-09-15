-- Рекурсивное обобщенное табличное выражение для поиска всех дочерних категорий

-- Создание временной таблицы Category с иерархической структурой
DROP TABLE if exists Category;
CREATE TEMP TABLE Category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    parentID INT,
    dateCreate DATE,
    dateChange DATE
);

-- Вставка тестовых данных в временную таблицу Category
INSERT INTO Category (name, parentID, dateCreate, dateChange) VALUES
('Electronics', NULL, CURRENT_DATE, CURRENT_DATE),
('Computers', 1, CURRENT_DATE, CURRENT_DATE),
('Laptops', 2, CURRENT_DATE, CURRENT_DATE),
('Smartphones', 1, CURRENT_DATE, CURRENT_DATE),
('Gaming Laptops', 3, CURRENT_DATE, CURRENT_DATE),
('Ultrabooks', 3, CURRENT_DATE, CURRENT_DATE),
('Android Phones', 4, CURRENT_DATE, CURRENT_DATE),
('iPhones', 4, CURRENT_DATE, CURRENT_DATE);

-- Рекурсивное CTE для поиска всех дочерних категорий
WITH RECURSIVE CategoryHierarchy AS (
    SELECT 
        id,
        name,
        parentID
    FROM 
        Category
    WHERE 
        id = 1  -- ID начальной категории, для которой ищем дочерние

    UNION ALL

    SELECT 
        c.id,
        c.name,
        c.parentID
    FROM 
        Category c
    INNER JOIN 
        CategoryHierarchy ch ON c.parentID = ch.id
)
SELECT * FROM CategoryHierarchy;
