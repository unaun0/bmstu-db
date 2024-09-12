-- Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом;

select name, phone from client
where exists(
	select * from purchase
	where clientID = client.id
	and status LIKE 'Выполнен'
);