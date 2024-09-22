-- Хранимая процедура доступа к метаданным

CREATE OR REPLACE PROCEDURE get_table_metadata(p_table_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    column_record RECORD;
BEGIN
    FOR column_record IN
        SELECT
            column_name,
            data_type,
            is_nullable
        FROM
            information_schema.columns
        WHERE
            table_name = p_table_name
    LOOP
        RAISE NOTICE 'Столбец: %, Тип данных: %, Может быть NULL: %',
            column_record.column_name,
            column_record.data_type,
            column_record.is_nullable;
    END LOOP;
END;
$$;

call get_table_metadata('purchase');
