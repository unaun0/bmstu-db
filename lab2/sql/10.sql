-- Инструкция SELECT, использующая поисковое выражение CASE;
select
	name,
	case
        WHEN price < 5000 THEN 'Дешевый'
		WHEN price < 25000 THEN 'Обычный'
		WHEN price < 50000 THEN 'Дорогой'
        ELSE 'Очень дорогой'
    end as priceStatus
from 
    product;
