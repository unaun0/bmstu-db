-- Инструкция SELECT, использующая поисковое выражение CASE;
-- Получить список товаров со статусом цены;
SELECT
	name,
	CASE
        WHEN price < 5000 THEN 'Дешевый'
		WHEN price < 25000 THEN 'Обычный'
		WHEN price < 50000 THEN 'Дорогой'
        ELSE 'Очень дорогой'
    END AS priceStatus
FROM 
    product;
