-- Инструкция SELECT, использующая простое выражение CASE;

select id, status,
    case 
        WHEN EXTRACT(YEAR FROM dateCreate) = EXTRACT(YEAR FROM NOW()) THEN 'Текущий год'
		WHEN EXTRACT(YEAR FROM dateCreate) = EXTRACT(YEAR FROM NOW()) - 1 THEN 'Прошлый год'
        ELSE 'Другой год'
    end as yearStatus
from
    purchase;