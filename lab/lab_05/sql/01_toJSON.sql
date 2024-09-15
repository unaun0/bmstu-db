-- Извлечь данные в JSON

SELECT row_to_json(p)
FROM Purchase p;

SELECT row_to_json(pr)
FROM Product pr;

SELECT row_to_json(c)
FROM Client c;

SELECT row_to_json(m)
FROM Manufacturer m;

SELECT row_to_json(s)
FROM Store s;
