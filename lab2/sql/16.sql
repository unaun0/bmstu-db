-- Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
-- строки значений;

-- Добавить продукт

DELETE FROM Product
WHERE id = 1013;

INSERT INTO Product (id, name, manufacturerID, price, dateCreate, dateChange)
VALUES (1013, 'Жвательная резинка LOVE IS...', 5, 1, NOW(), NOW());

select * from Product
where id = 1013;