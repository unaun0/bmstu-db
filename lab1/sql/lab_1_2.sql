-- Удаление ограничений

ALTER TABLE Product
	DROP CONSTRAINT IF EXISTS fk_product_manufacturer_id CASCADE,
	DROP CONSTRAINT IF EXISTS pk_product_id CASCADE,
	DROP CONSTRAINT IF EXISTS product_date_create_check,
	DROP CONSTRAINT IF EXISTS product_date_change_check,
	DROP CONSTRAINT IF EXISTS product_price_check;

ALTER TABLE Client
	DROP CONSTRAINT IF EXISTS pk_client_id CASCADE,
	DROP CONSTRAINT IF EXISTS client_date_create_check,
	DROP CONSTRAINT IF EXISTS client_date_change_check;

ALTER TABLE Manufacturer
	DROP CONSTRAINT IF EXISTS pk_manufacturer_id CASCADE,
	DROP CONSTRAINT IF EXISTS manufacturer_date_create_check,
	DROP CONSTRAINT IF EXISTS manufacturer_date_change_check;

ALTER TABLE Store
	DROP CONSTRAINT IF EXISTS pk_store_id CASCADE,
	DROP CONSTRAINT IF EXISTS store_date_create_check,
	DROP CONSTRAINT IF EXISTS store_date_change_check;


ALTER TABLE Purchase
	DROP CONSTRAINT IF EXISTS purchase_date_create_check,
	DROP CONSTRAINT IF EXISTS purchase_date_change_check,
	DROP CONSTRAINT IF EXISTS purchase_productCount_check,
	DROP CONSTRAINT IF EXISTS purchase_status_check,
	DROP CONSTRAINT IF EXISTS pk_purchase_id CASCADE,
	DROP CONSTRAINT IF EXISTS fk_purchase_product_id CASCADE,
	DROP CONSTRAINT IF EXISTS fk_purchase_store_id CASCADE,
	DROP CONSTRAINT IF EXISTS fk_purchase_client_id CASCADE;

---------------------------------------------------------------------------

-- Ограничения для Client
ALTER TABLE Client
	
-- Добавляем первичный ключ на поле id
	ADD CONSTRAINT pk_client_id PRIMARY KEY (id),

-- Добавляем ограничения NOT NULL для полей, которые не могут быть пустыми
	ALTER COLUMN name SET NOT NULL,
	ALTER COLUMN phone SET NOT NULL,
	ALTER COLUMN dateCreate SET NOT NULL,
	ALTER COLUMN dateChange SET NOT NULL,

-- Добавляем ограничение, чтобы dateCreate не могла быть больше текущей даты
	ADD CONSTRAINT client_date_create_check CHECK (dateCreate <= CURRENT_DATE),

-- Добавляем ограничение, чтобы dateChange не могла быть меньше dateCreate
	ADD CONSTRAINT client_date_change_check CHECK (dateChange <= CURRENT_DATE AND dateChange >= dateCreate);

---------------------------------------------------------------------------

-- Ограничения для Manufacturer
ALTER TABLE Manufacturer

	-- Добавляем ограничение на первичный ключ id
	ADD CONSTRAINT pk_manufacturer_id PRIMARY KEY(id),

	-- Добавляем ограничение NOT NULL для атрибутов
	ALTER COLUMN name SET NOT NULL,
	ALTER COLUMN email SET NOT NULL,

	-- Добавляем ограничение для атрибута dataCreate
	ADD CONSTRAINT manufacturer_date_create_check CHECK (dateCreate <= CURRENT_DATE),

	-- Добавляем ограничение для атрибута dataChange
	ADD CONSTRAINT manufacturer_date_change_check CHECK (dateChange >= dateCreate AND dateChange <= CURRENT_DATE);

---------------------------------------------------------------------------

-- Ограничения для Store
ALTER TABLE Store

	-- Добавляем ограничение на первичный ключ id
	ADD CONSTRAINT pk_store_id PRIMARY KEY(id),

	-- Добавляем ограничение NOT NULL для атрибутов
	ALTER COLUMN name SET NOT NULL,
	ALTER COLUMN email SET NOT NULL,

	-- Добавляем ограничение для атрибута dataCreate
	ADD CONSTRAINT store_date_create_check CHECK (dateCreate <= CURRENT_DATE),

	-- Добавляем ограничение для атрибута dataChange
	ADD CONSTRAINT store_date_change_check CHECK (dateChange >= dateCreate AND dateChange <= CURRENT_DATE);

---------------------------------------------------------------------------

-- Ограничения для Product
ALTER TABLE Product
	
	-- Добавляем ограничение на первичный ключ id
	ADD CONSTRAINT pk_product_id PRIMARY KEY(id),

	-- Добавляем ограничение NOT NULL для атрибутов
	ALTER COLUMN manufacturerID SET NOT NULL,
	ALTER COLUMN price SET NOT NULL,

	-- Добавляем внешний ключ для поля manufacturerID
	ADD CONSTRAINT fk_product_manufacturer_id FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(id) ON DELETE SET NULL,

	-- Добавляем ограничение для атрибута dataCreate
	ADD CONSTRAINT product_date_create_check CHECK (dateCreate <= CURRENT_DATE),

	-- Добавляем ограничение для атрибута dataChange
	ADD CONSTRAINT product_date_change_check CHECK (dateChange >= dateCreate AND dateChange <= CURRENT_DATE),

	-- Добавляем ограничение для атрибута price
	ADD CONSTRAINT product_price_check CHECK (price >= 0.0);

---------------------------------------------------------------------------

-- Ограничения для Purchase
ALTER TABLE Purchase
	-- Добавляем ограничение на первичный ключ id
	ADD CONSTRAINT pk_purchase_id PRIMARY KEY(id),

	-- Добавляем внешний ключ для поля productID
	ADD CONSTRAINT fk_purchase_product_id FOREIGN KEY (productID) REFERENCES Product(id),

	-- Добавляем внешний ключ для поля clientID
	ADD CONSTRAINT fk_purchase_client_id FOREIGN KEY (clientID) REFERENCES Client(id),

	-- Добавляем внешний ключ для поля storeID
	ADD CONSTRAINT fk_purchase_store_id FOREIGN KEY (storeID) REFERENCES Store(id),

	-- Добавляем ограничение для атрибута dataCreate
	ADD CONSTRAINT purchase_date_create_check CHECK (dateCreate <= CURRENT_DATE),

	-- Добавляем ограничение для атрибута dataChange
	ADD CONSTRAINT purchase_date_change_check CHECK (dateChange >= dateCreate AND dateChange <= CURRENT_DATE),

	-- Добавляем ограничение для атрибута productCount
	ADD CONSTRAINT purchase_productCount_check CHECK (productCount > 0),

	-- Добавляем ограничение для атрибута status
	ADD CONSTRAINT purchase_status_check CHECK (
		status = 'В обработке' OR 
		status = 'Отменен' OR 
		status = 'Выполнен' OR
		status = 'Отправлен'
	);

---------------------------------------------------------------------------

-- Ограничения для Review
--ALTER TABLE Review
	-- Добавляем ограничение на первичный ключ id
--	ADD CONSTRAINT pk_review_id PRIMARY KEY(id),
	
	-- Добавляем внешний ключ для атрибут productID
--	ADD CONSTRAINT fk_review_product_id FOREIGN KEY (productID) REFERENCES Product(id),

	-- Добавляем внешний ключ для атрибута clientID
--	ADD CONSTRAINT fk_review_client_id FOREIGN KEY (clientID) REFERENCES Client(id),

	-- Добавляем ограничение для атрибута rating
--	ADD CONSTRAINT review_rating_check CHECK (rating BETWEEN 1 AND 5)