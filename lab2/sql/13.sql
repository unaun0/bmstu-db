-- Инструкция SELECT использующая вложенные подзапросы с уровнем вложенности 3;

select id, name, phone from client
where id in (
	select clientID from purchase
	where productID in (
		select id from product
		where dateCreate <= '2024-09-01' and product.manufacturerid in (
			select id from manufacturer
			where dateCreate >= '2024-01-01'
			)
	) and status = 'Выполнен'
);