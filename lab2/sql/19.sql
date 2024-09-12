-- Инструкция UPDATE со скалярным подзапросом в предложении SET;

UPDATE Product
SET price = (
	SELECT AVG(productCount)
	FROM purchase 
	WHERE productID = 114
)
WHERE id = 444;