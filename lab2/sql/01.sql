-- Инструкция SELECT, использующая предикат сравнения;
-- Получить имя и email клиента, который заказал продукт с id 671;
SELECT DISTINCT C.name, C.email
FROM client C JOIN purchase AS P ON P.clientID = C.id 
	AND P.productId = 671
ORDER BY C.name;