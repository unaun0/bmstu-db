-- Инструкция SELECT, использующая предикат сравнения с квантором;

SELECT * FROM purchase
WHERE productCount > ALL (
	SELECT productCount FROM purchase
	WHERE productID = 720
);