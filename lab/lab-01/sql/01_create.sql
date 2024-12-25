-- База данных сети магазинов товаров

--CREATE DATABASE market;

-- Удаляем существующие таблицы
DROP TABLE IF EXISTS Purchase CASCADE;
DROP TABLE IF EXISTS Product CASCADE;
DROP TABLE IF EXISTS Store CASCADE;
DROP TABLE IF EXISTS Manufacturer CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Client CASCADE;

-- Создаем таблицы

CREATE TABLE Client (
    id SERIAL,
    name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255),
    dateOfBirth DATE,
    dateCreate DATE,
    dateChange DATE
);

CREATE TABLE Manufacturer (
    id SERIAL,
    name VARCHAR(255),
    email VARCHAR(255),
    URL VARCHAR(255),
    dateCreate DATE,
    dateChange DATE
);

CREATE TABLE Store (
    id SERIAL,
    name VARCHAR(255),
    email VARCHAR(255),
    URL VARCHAR(255),
    dateCreate DATE,
    dateChange DATE
);

CREATE TABLE Product (
    id SERIAL,
    name VARCHAR(255),
    manufacturerID INT,
    price DECIMAL(10, 2),
    dateCreate DATE,
    dateChange DATE
);

CREATE TABLE Purchase (
    id SERIAL,
    storeID INT,
    clientID INT,
    productID INT,
    productCount INT,
    status VARCHAR(255),
    dateCreate DATE,
    dateChange DATE
);

--CREATE TABLE Review (
--    id SERIAL,
--    productID INT,
--    clientID INT,
--    rating INT,
--    comment TEXT,
--    dateCreate DATE,
--    dateChange DATE
--);


