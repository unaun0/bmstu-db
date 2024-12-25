-- CREATE EXTENSION plpython3u;

-- Скалярная функция

CREATE OR REPLACE FUNCTION is_active(status varchar)
RETURNS bool
LANGUAGE plpython3u
AS $$
	if status == 'В обработке':
		return True
	else:
		return False
$$;

SELECT id, status, is_active(status) FROM purchase ORDER BY id;