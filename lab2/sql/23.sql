-- Рекурсивное обобщенное табличное выражение для поиска всех дочерних категорий
WITH RECURSIVE ChildCategories AS (
    -- Начальное условие: выбираем дочерние категории для определенной категории
    SELECT
        id,
        name,
        parentID
    FROM
        Category
    WHERE
        id = 145 -- Начальная категория, для которой ищем дочерние категории

    UNION ALL

    -- Рекурсивное членение: выбираем дочерние категории для каждой найденной категории
    SELECT
        c.id,
        c.name,
        c.parentID
    FROM
        Category c
    JOIN
        ChildCategories cc ON c.parentID = cc.id
)
-- Основной запрос, использующий рекурсивное CTE
SELECT
    id,
    name,
    parentID
FROM
    ChildCategories;