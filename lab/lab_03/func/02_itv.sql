-- Подставляемая табличная функция

CREATE OR REPLACE FUNCTION get_purchases_by_client(client_id INT)
RETURNS TABLE (
    purchase_id INT,
    product_name VARCHAR,
    store_name VARCHAR,
    product_count INT,
    status VARCHAR,
    purchase_date DATE
) AS $$
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
        p.clientID = client_id;
$$ LANGUAGE SQL;

select * from get_purchases_by_client(22);
