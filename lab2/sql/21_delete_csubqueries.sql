-- Инструкция DELETE с вложенным коррелированным подзапросом в 
-- предложении WHERE;

DELETE FROM Purchase p
WHERE EXISTS (
	select 1 from Product pr
    WHERE pr.id = p.productID
      AND p.status = 'Выполнен'
);