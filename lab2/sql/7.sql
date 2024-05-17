-- Инструкция SELECT, использующая агрегатные функции в выражениях столбцов;
-- Получить среднее значение единиц товаров для выполненных заказов;
SELECT 	AVG(productCount) AS "avg", 
	  	SUM(productCount) / COUNT(productCount) AS "avgCalc"
FROM purchase
WHERE status = 'Выполнен';