-- Инструкция SELECT, использующая простое выражение CASE;
-- Получаем список заказов со статусом года создания;
SELECT 
    id, 
    status,
    dateCreate,
    CASE 
        WHEN EXTRACT(YEAR FROM dateCreate) = EXTRACT(YEAR FROM NOW()) THEN 'Текущий год'
		WHEN EXTRACT(YEAR FROM dateCreate) = EXTRACT(YEAR FROM NOW()) - 1 THEN 'Прошлый год'
        ELSE 'Другой год'
    END AS yearStatus
FROM 
    purchase;