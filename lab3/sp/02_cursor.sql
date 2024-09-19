-- Хранимая процедура с курсором

CREATE OR REPLACE PROCEDURE increase_product_count()
LANGUAGE plpgsql
AS $$
DECLARE
    purchase_record RECORD;  
    purchase_cursor CURSOR FOR
        SELECT id, productCount
        FROM Purchase;
BEGIN
    OPEN purchase_cursor;

    LOOP
        FETCH purchase_cursor INTO purchase_record;
        EXIT WHEN NOT FOUND;
        UPDATE Purchase
        SET productCount = purchase_record.productCount + 1,
            dateChange = CURRENT_DATE
        WHERE id = purchase_record.id;

        RAISE NOTICE 'Обновлено количество продуктов - % для заказа №%',
            purchase_record.productCount + 1, purchase_record.id;
    END LOOP;

    CLOSE purchase_cursor;
END;
$$;

call increase_product_count();
