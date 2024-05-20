-- Оконные функции;
SELECT
    id,
    storeID,
    clientID,
    productID,
    productCount,
    MIN(productCount) OVER() AS minProductCount,
	MAX(productCount) OVER() AS maxProductCount,
	AVG(productCount) OVER() AS avgProductCount
FROM
    Purchase;
