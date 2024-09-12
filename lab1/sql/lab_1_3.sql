-- Загрузка данных для клиентов
COPY Client(id, name, email, phone, dateOfBirth, dateCreate, dateChange) 
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/lab1/tables/clients.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для производителей
COPY Manufacturer(id, name, email, URL, dateCreate, dateChange) 
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/lab1/tables/manufacturers.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для магазинов
COPY Store(id, name, email, URL, dateCreate, dateChange) 
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/lab1/tables/stores.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для продуктов
COPY Product(id, name, manufacturerID, price, dateCreate, dateChange) 
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/lab1/tables/products.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для покупок
COPY Purchase(id, storeID, clientID, productID, productCount, status, dateCreate, dateChange) 
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/lab1/tables/purchases.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для отзывов
--COPY Review(id, productID, clientID, rating, comment, dateCreate, dateChange) 
--  FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/lab1/tables/reviews.csv' DELIMITER ',' CSV HEADER;
