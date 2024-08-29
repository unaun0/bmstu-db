-- Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом;
-- Получить список выполненных заказов товаров, поставки которых были меньше 10 единиц;
SELECT id, status 
FROM purchase
WHERE EXISTS (
	SELECT * FROM delivery
	WHERE productID = purchase.productID
	AND count < 10 
) AND status = 'Выполнен';