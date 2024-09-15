-- Хранимая процедура с параметрами

CREATE OR REPLACE PROCEDURE update_product_count(purchase_id INT, new_count INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Обновляем количество продуктов в покупке
    UPDATE Purchase
    SET productCount = new_count, dateChange = CURRENT_DATE
    WHERE id = purchase_id;

    -- Если количество продуктов меньше 0, выдаем предупреждение
    IF new_count < 0 THEN
        RAISE WARNING 'Количество продуктов не может быть отрицательным';
    END IF;
END;
$$;

CALL update_product_count(1, 2);

