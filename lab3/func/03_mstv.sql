-- Многооператорная табличная функция

CREATE OR REPLACE FUNCTION get_purchases_with_status(client_id INT, purchase_status VARCHAR, from_date DATE)
RETURNS TABLE (
    purchase_id INT,
    product_name VARCHAR,
    store_name VARCHAR,
    product_count INT,
    status VARCHAR,
    purchase_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS purchase_id,
        prod.name AS product_name,
        s.name AS store_name,
        p.productCount,
        p.status,
        p.dateCreate AS purchase_date
    FROM 
        Purchase p
    JOIN 
        Product prod ON p.productID = prod.id
    JOIN 
        Store s ON p.storeID = s.id
    WHERE 
        p.clientID = client_id
        AND p.status = purchase_status
        AND p.dateCreate >= from_date;
END;
$$ LANGUAGE plpgsql;

select * from get_purchases_with_status(1, 'В обработке', '2000-01-01');
