import csv
import random
from faker import Faker
from datetime import datetime, timedelta
import os
from namesBase import categoriesBase, productsBase

tablesFolderPath = os.getcwd() + '/tables'

class MarketDataGenerator:
    fakeRU = Faker('ru_RU')
    fakeEN = Faker('en_US')
    currentDate = datetime.now().date()

    def __init__(self) -> None:
        os.makedirs(tablesFolderPath) if not os.path.exists(tablesFolderPath) else None

        return super(MarketDataGenerator, self).__init__()

    # Генерация данных для клиентов
    def generateClients(self, count):
        clients = []
        for i in range(count):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            clients.append([
                i + 1,
                self.fakeRU.name(),
                self.fakeRU.email(), 
                self.fakeRU.phone_number(), 
                self.fakeRU.date_of_birth(
                    minimum_age=14, 
                    maximum_age=90
                ),
                dateCreate,
                self.fakeRU.date_between_dates(
                    date_start=dateCreate,
                    date_end=self.currentDate,
                ) 
            ])
            
        return clients

    # Генерация данных для категорий
    def generateCategories(self, count):
        categories = []
        for i in range(count):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            categories.append([
                i + 1,
                random.choice(list(range(1, i + 2))), 
                self.fakeRU.random_element(categoriesBase) + ' ' + self.fakeEN.word(), 
                dateCreate,
                self.fakeRU.date_between_dates(
                    date_start=dateCreate, 
                    date_end=self.currentDate,
                )
            ])
        return categories

    # Генерация данных для производителей
    def generateManufacturers(self, count):
        manufacturers = []
        for i in range(count):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            manufacturers.append([
                i + 1,
                self.fakeRU.company() + self.fakeEN.word(),
                self.fakeRU.email(), 
                self.fakeRU.url(), 
                dateCreate,
                self.fakeRU.date_between_dates(
                    date_start=dateCreate, 
                    date_end=self.currentDate,
                )
            ])
        return manufacturers

    # Генерация данных для магазинов
    def generateStores(self, count):
        stores = []
        for i in range(count):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            stores.append([
                i + 1,
                self.fakeEN.word().capitalize() + self.fakeEN.word(),
                self.fakeRU.email(), 
                self.fakeRU.url(), 
                dateCreate,
                self.fakeRU.date_between_dates(
                    date_start=dateCreate, 
                    date_end=self.currentDate,
                )
            ])
            
        return stores

    # Генерация данных для поставок
    def generateDeliveries(self, deliveriesCount, productsCount, storesCount):
        deliveries = []
        for i in range(deliveriesCount):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            deliveries.append([
                i + 1,
                random.randint(1, productsCount),
                random.randint(1, storesCount),
                random.randint(1, 1000),
                self.fakeRU.date_between_dates(
                    date_start=self.currentDate,
                ),
                dateCreate,
                self.fakeRU.date_between_dates(
                    date_start=dateCreate, 
                    date_end=self.currentDate,
                )
            ])
            
        return deliveries

    # Генерация данных для продуктов
    def generateProducts(self, productsCount, manufacturersCount, categoriesCount):
        products = []
        for i in range(productsCount):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            products.append([
                i + 1,
                (self.fakeRU.random_element(productsBase) + ' ' + 
                self.fakeEN.word() + ' ' + self.fakeEN.word()
                ),
                random.randint(1, manufacturersCount), 
                random.randint(1, categoriesCount),
                round(
                    random.uniform(1, 100000), 
                    2
                ),
                dateCreate,
                self.fakeRU.date_between_dates(
                    date_start=dateCreate, 
                    date_end=self.currentDate,
                )
            ])
            
        return products

    # Генерация данных для покупок
    def generatePurchases(self, purchasesCount, storesCount, clientsCount, productsCount):
        purchases = []
        for i in range(purchasesCount):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            purchases.append([
                i + 1,
                random.randint(1, storesCount),
                random.randint(1, clientsCount),
                random.randint(1, productsCount),
                random.randint(1, 100), 
                random.choice(['В обработке', 'Отправлен', 'Отменен', 'Выполнен']),
                dateCreate,
                self.fakeRU.date_between_dates(
                    date_start=dateCreate, 
                    date_end=self.currentDate,
                )
            ])
            
        return purchases

    # Запись данных в CSV файлы
    def writeToCsv(self, data, filename):
        with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow('')
            writer.writerows(data)

    def generate(self, count):
    # Генерация данных
        self.writeToCsv(self.generateClients(count), 'tables/clients.csv')
        self.writeToCsv(self.generateCategories(count), 'tables/categories.csv')
        self.writeToCsv(self.generateManufacturers(count), 'tables/manufacturers.csv')
        self.writeToCsv(self.generateStores(count), 'tables/stores.csv')
        self.writeToCsv(self.generateDeliveries(count, count, count), 'tables/deliveries.csv')
        self.writeToCsv(self.generateProducts(count, count, count), 'tables/products.csv')
        self.writeToCsv(self.generatePurchases(count, count, count, count), 'tables/purchases.csv')
