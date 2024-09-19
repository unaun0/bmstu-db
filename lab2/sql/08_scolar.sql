-- Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов;

select name, phone, 
(
	select avg(productCount) from Purchase
	where Purchase.clientID = Client.ID
) as "Среднее количество товаров в заказе"
from client;

