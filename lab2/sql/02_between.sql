-- Инструкция SELECT, использующая предикат BETWEEN;

SELECT * FROM purchase 
WHERE dateCreate BETWEEN '2024-01-01' AND '2025-01-01'
ORDER BY id;