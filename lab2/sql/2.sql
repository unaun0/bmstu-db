-- Инструкция SELECT, использующая предикат BETWEEN;
-- Получить id и статус заказа, дата создания которого между опр. датами;
SELECT DISTINCT id, status
FROM purchase 
WHERE dateCreate BETWEEN '2024-01-01' AND '2024-04-01'
ORDER BY id;