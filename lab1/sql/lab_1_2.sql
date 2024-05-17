ALTER TABLE Category
	DROP CONSTRAINT IF EXISTS category_dateCreate_check,
	ADD CONSTRAINT category_dateCreate_check CHECK (dateCreate <= NOW()),
	
	DROP CONSTRAINT IF EXISTS category_dateChange_check,
	ADD CONSTRAINT category_dateChange_check CHECK (dateChange <= NOW());

---------------------------------------------------------------------------

ALTER TABLE Delivery
	DROP CONSTRAINT IF EXISTS delivery_dateCreate_check,
	ADD CONSTRAINT delivery_dateCreate_check CHECK (dateCreate <= NOW()),
	
	DROP CONSTRAINT IF EXISTS delivery_dateChange_check,
	ADD CONSTRAINT delivery_dateChange_check CHECK (dateChange <= NOW()),
	
	DROP CONSTRAINT IF EXISTS delivery_dateDelivery_check,
	ADD CONSTRAINT delivery_dateDelivery_check CHECK (datedelivery >= datecreate AND datedelivery >= datechange),
	
	DROP CONSTRAINT IF EXISTS delivery_count_check,
	ADD CONSTRAINT delivery_count_check CHECK (count > 0);

---------------------------------------------------------------------------

ALTER TABLE Product
	DROP CONSTRAINT IF EXISTS product_dateCreate_check,
	ADD CONSTRAINT product_dateCreate_check CHECK (dateCreate <= NOW()),
	
	DROP CONSTRAINT IF EXISTS product_dateChange_check,
	ADD CONSTRAINT product_dateChange_check CHECK (dateChange <= NOW()),
	
	DROP CONSTRAINT IF EXISTS product_price_check,
	ADD CONSTRAINT product_price_check CHECK (price >= 0);
	
---------------------------------------------------------------------------

ALTER TABLE Purchase
	
	DROP CONSTRAINT IF EXISTS purchase_dateCreate_check,
	ADD CONSTRAINT purchase_dateCreate_check CHECK (dateCreate <= NOW()),
	
	DROP CONSTRAINT IF EXISTS purchase_dateChange_check,
	ADD CONSTRAINT purchase_dateChange_check CHECK (dateChange <= NOW()),
	
	DROP CONSTRAINT IF EXISTS purchase_productCount_check,
	ADD CONSTRAINT purchase_productCount_check CHECK (productCount > 0),
	
	DROP CONSTRAINT IF EXISTS purchase_status_check,
	ADD CONSTRAINT purchase_status_check CHECK (
		status = 'В обработке' OR 
		status = 'Отменен' OR 
		status = 'Выполнен' OR
		status = 'Отправлен'
	);
