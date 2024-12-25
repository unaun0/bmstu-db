-- Инструкция SELECT, использующая предикат IN с вложенным подзапросом;

select * from Purchase
where productID in (
	select id from client
	where dateOfBirth <= '2003-01-01'
) and status = 'Выполнен';