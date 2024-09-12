-- Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM;

select * from product pr
where pr.manufacturerid IN (
	select id 
	from manufacturer m
    where m.id = pr.id
);