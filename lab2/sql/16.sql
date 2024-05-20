-- Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
-- строки значений;
-- Добавить продукт
INSERT INTO Product (id, name, manufacturerID, price, dateCreate, dateChange)
VALUES (1050, 'Жвательная резинка LOVE IS...', 5, 1, NOW(), NOW())