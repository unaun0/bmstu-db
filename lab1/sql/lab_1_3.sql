-- Загрузка данных для клиентов
COPY Client(id, name, email, phone, dateOfBirth, dateCreate, dateChange) 
FROM '/Users/yanatsaha0/Desktop/NEW/БД/bmstu-db/lab1/tables/clients.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для категорий
COPY Category(id, parentID, name, dateCreate, dateChange) 
FROM '/Users/yanatsaha0/Desktop/NEW/БД/bmstu-db/lab1/tables/categories.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для производителей
COPY Manufacturer(id, name, email, websiteURL, dateCreate, dateChange) 
FROM '/Users/yanatsaha0/Desktop/NEW/БД/bmstu-db/lab1/tables/manufacturers.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для магазинов
COPY Store(id, name, email, websiteURL, dateCreate, dateChange) 
FROM '/Users/yanatsaha0/Desktop/NEW/БД/bmstu-db/lab1/tables/stores.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для поставок
COPY Delivery(id, productID, storeID, count, dateDelivery, dateCreate, dateChange) 
FROM '/Users/yanatsaha0/Desktop/NEW/БД/bmstu-db/lab1/tables/deliveries.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для продуктов
COPY Product(id, name, manufacturerID, categoryID, price, dateCreate, dateChange) 
FROM '/Users/yanatsaha0/Desktop/NEW/БД/bmstu-db/lab1/tables/products.csv' DELIMITER ',' CSV HEADER;

-- Загрузка данных для покупок
COPY Purchase(id, storeID, clientID, productID, productCount, status, dateCreate, dateChange) 
FROM '/Users/yanatsaha0/Desktop/NEW/БД/bmstu-db/lab1/tables/purchases.csv' DELIMITER ',' CSV HEADER;

