-- Скалярная функция

CREATE OR REPLACE FUNCTION total_purchase_cost(p_id INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    total_cost DECIMAL(10, 2);
BEGIN
    SELECT price * productCount INTO total_cost
    FROM Purchase
    JOIN Product ON Purchase.productID = Product.id
    WHERE Purchase.id = p_id;
    RETURN total_cost;
END;
$$ LANGUAGE plpgsql;

SELECT 
	id,
	total_purchase_cost(id) as "Итоговая цена"
FROM purchase;

