-- Инструкция SELECT, использующая агрегатные функции в выражениях столбцов;

SELECT 	AVG(productCount) AS "avg", 
	  	SUM(productCount) / COUNT(productCount) AS "avgCalc"
FROM purchase
WHERE status = 'Выполнен';