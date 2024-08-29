-- Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов;
-- Получить список заказов + общее количество заказанного товара 
-- и остаток после выполнения заказа;
SELECT id, productID, productCount, (
	SELECT SUM(count) FROM delivery
	WHERE delivery.productID = purchase.productID
)  AS "deliveriedCount",
(
	SELECT SUM(count) FROM delivery
	WHERE delivery.productID = purchase.productID
) - productCount AS "Остаток"
FROM purchase
WHERE status = 'Выполнен';