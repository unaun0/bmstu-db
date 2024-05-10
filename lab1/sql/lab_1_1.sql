-- База данных сети магазинов товаров

-- DROP DATABASE IF EXISTS market;

--CREATE DATABASE market
--    WITH
--    OWNER = postgres
--    ENCODING = 'UTF8'
--    LC_COLLATE = 'en_US.UTF-8'
--    LC_CTYPE = 'en_US.UTF-8'
--    ICU_LOCALE = 'en-US'
--    LOCALE_PROVIDER = 'icu'
--    TABLESPACE = pg_default
--    CONNECTION LIMIT = -1
--    IS_TEMPLATE = False;

DROP TABLE IF EXISTS Client CASCADE;
CREATE TABLE Client(
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR(255) NOT NULL,
	email VARCHAR(255) DEFAULT NULL,
	phone VARCHAR(255) DEFAULT NULL,
	dateofBirth DATE NOT NULL,
	dateCreate DATE NOT NULL,
	dateChange DATE NOT NULL
);

DROP TABLE IF EXISTS Category CASCADE;
CREATE TABLE Category(
	id SERIAL PRIMARY KEY NOT NULL,
	parentID SERIAL,
	FOREIGN KEY (parentID) REFERENCES Category(id) ON DELETE SET NULL,
	name VARCHAR(255) NOT NULL,
	dateCreate DATE NOT NULL,
	dateChange DATE NOT NULL
);

DROP TABLE IF EXISTS Manufacturer CASCADE;
CREATE TABLE Manufacturer(
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR(255) NOT NULL,
	email VARCHAR(255) DEFAULT NULL,
	websiteURL VARCHAR(255),
	dateCreate DATE NOT NULL,
	dateChange DATE NOT NULL
);

DROP TABLE IF EXISTS Store CASCADE;
CREATE TABLE Store(
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR(255) NOT NULL,
	email VARCHAR(255) DEFAULT NULL,
	websiteURL VARCHAR(255),
	dateCreate DATE NOT NULL,
	dateChange DATE NOT NULL
);

DROP TABLE IF EXISTS Delivery;
CREATE TABLE Delivery(
	id SERIAL PRIMARY KEY NOT NULL, 
	productID SERIAL,
	storeID SERIAL, 
	FOREIGN KEY (productID) REFERENCES Product(id) ON DELETE CASCADE,
	FOREIGN KEY (storeID) REFERENCES Store(id) ON DELETE CASCADE,
	count INT NOT NULL,
	dateDelivery DATE NOT NULL,
	dateCreate DATE NOT NULL,
	dateChange DATE NOT NULL
);

DROP TABLE IF EXISTS Product CASCADE;
CREATE TABLE Product(
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR(255) NOT NULL,
	manufacturerID INT,
	categoryID INT,
	FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(id) ON DELETE CASCADE,
	FOREIGN KEY (categoryID) REFERENCES Category(id) ON DELETE CASCADE,
	price  DECIMAL(10, 2) NOT NULL,
	dateCreate DATE NOT NULL,
	dateChange DATE NOT NULL
);

DROP TABLE IF EXISTS Purchase;
CREATE TABLE Purchase(
	id SERIAL PRIMARY KEY NOT NULL,
	storeID INT,
	clientID INT,
	productID INT,
	FOREIGN KEY (storeID) REFERENCES Store(id) ON DELETE CASCADE,
	FOREIGN KEY (clientID) REFERENCES Client(id) ON DELETE CASCADE,
	FOREIGN KEY (productID) REFERENCES Product(id) ON DELETE CASCADE,
	productCount INT NOT NULL DEFAULT 0,
	status VARCHAR(255) NOT NULL DEFAULT 'В обработке',
	dateCreate DATE NOT NULL,
	dateChange DATE NOT NULL
);