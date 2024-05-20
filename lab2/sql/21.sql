-- Инструкция DELETE с вложенным коррелированным подзапросом в 
-- предложении WHERE;
DELETE FROM Purchase p
WHERE EXISTS (
    SELECT 1
    FROM Product pr
    JOIN Category c ON pr.categoryID = c.id
    WHERE pr.id = p.productID
      AND p.status = 'Выполнен'
);