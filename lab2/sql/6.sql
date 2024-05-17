-- Инструкция SELECT, использующая предикат сравнения с квантором;
-- Получить список заказов товара, количество которого больше любого 
-- значения количества товара заказа с id продукта равным 782;
SELECT * FROM purchase
WHERE productCount > ALL (
	SELECT productCount FROM purchase
	WHERE productID = 782
);