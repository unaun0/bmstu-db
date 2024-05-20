-- Простая инструкция UPDATE;
-- Обновить цену для продукта;
UPDATE Product 
SET price = price * 5
WHERE id = 1050;