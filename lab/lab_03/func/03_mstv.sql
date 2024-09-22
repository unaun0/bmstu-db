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
DECLARE
    -- Объявляем переменные для каждой колонки
    _purchase_id INT;
    _product_name VARCHAR;
    _store_name VARCHAR;
    _product_count INT;
    _status VARCHAR;
    _purchase_date DATE;
BEGIN
    -- Вставляем данные в переменные построчно
    FOR _purchase_id, _product_name, _store_name, _product_count, _status, _purchase_date IN
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
            AND p.dateCreate >= from_date
    LOOP
        -- Устанавливаем значения для выходных параметров
        purchase_id := _purchase_id;
        product_name := _product_name;
        store_name := _store_name;
        product_count := _product_count;
        status := _status;
        purchase_date := _purchase_date;

        -- Возвращаем следующую строку
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

select * from get_purchases_with_status(1, 'В обработке', '2000-01-01');
