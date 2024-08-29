-- Инструкция SELECT, использующая предикат IN с вложенным подзапросом;
-- Получить список данных клиентов и их отмененных заказов товара, 
-- id производителя которого равен 845;
SELECT C.id, C.name, C.phone, P.id as purchaseID
FROM client C JOIN purchase AS P on P.clientID = C.id
WHERE P.productID IN (
	SELECT id AS productID FROM product
	WHERE manufacturerid = 845
) AND P.status = 'Отменен';