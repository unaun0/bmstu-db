import json
import psycopg2
import sys
from py_linq import Enumerable
from datetime import datetime
from config import DB_HOST, DB_PASS, DB_NAME, DB_PORT, DB_USER
from peewee import *

# Создаем подключение к базе данных PostgreSQL
con = PostgresqlDatabase(
    'market',  
    user=DB_USER,
    password=DB_PASS,
    host=DB_HOST,
    port=DB_PORT
)

# Определяем базовую модель для наследования
class BaseModel(Model):
    class Meta:
        database = con 

# Модель Client
class Client(BaseModel):
    id = IntegerField(primary_key=True)
    name = CharField(max_length=255)
    email = CharField(max_length=255)
    phone = CharField(max_length=255)
    dateofbirth = DateField(null=True)
    datecreate = DateField()
    datechange = DateField()

# Модель Manufacturer
class Manufacturer(BaseModel):
    id = IntegerField(primary_key=True)
    name = CharField(max_length=255)
    email = CharField(max_length=255)
    url = CharField(max_length=255)
    datecreate = DateField()
    datechange = DateField()

# Модель Store
class Store(BaseModel):
    id = IntegerField(primary_key=True)
    name = CharField(max_length=255)
    email = CharField(max_length=255)
    url = CharField(max_length=255)
    datecreate = DateField()
    datechange = DateField()

# Модель Product
class Product(BaseModel):
    id = IntegerField(primary_key=True)
    name = CharField(max_length=255)
    manufacturer = ForeignKeyField(Manufacturer, column_name='manufacturerid')
    price = DecimalField(max_digits=10, decimal_places=2)
    datecreate = DateField()
    datechange = DateField()


# Модель Purchase
class Purchase(BaseModel):
    id = IntegerField(primary_key=True)
    store = ForeignKeyField(Store, column_name='storeid', backref='purchases') 
    client = ForeignKeyField(Client, column_name='clientid', backref='purchases') 
    product = ForeignKeyField(Product, column_name='productid', backref='purchases') 
    productcount = IntegerField()
    status = CharField(max_length=255)
    datecreate = DateField()
    datechange = DateField()


# 1. Однотабличный запрос на выборку.
def select_products():
    products = (Product
                .select(Product.id, 
                        Product.name, 
                        Product.price).limit(5)
                .order_by(Product.id.desc())
                .where(Product.price > 50000))
    for product in products:
        print(product.id, product.name, product.price)
    return products

# 2. Многотабличный запрос на выборку.
def select_purchases_with_details():
    purchases = (Purchase
                 .select(Purchase, Client, Store, Product)
                 .join(Client, on=(Purchase.client == Client.id))  
                 .join(Store, on=(Purchase.store == Store.id))
                 .join(Product, on=(Purchase.product == Product.id))
                 .limit(5)) 
    
    for purchase in purchases:
        print(purchase.id, '|', purchase.client.name, '|', purchase.store.name,  '|', purchase.product.name)
    return purchases

# 3.1. Добавление
def add_client(id, name, email, phone, date_of_birth=None):
    new_client = Client.create(id=id, 
                               name=name, 
                               email=email, 
                               phone=phone, 
                               date_of_birth=date_of_birth,
                               datecreate=datetime.now().date(), 
                               datechange=datetime.now().date())
    print(f"Added Client: ID: {new_client.id}, Name: {new_client.name}")
    return new_client.id

# 3.2. Обновление
def update_client(client_id, new_email):
    client = Client.get(Client.id == client_id)
    client.email = new_email
    client.datechange = datetime.now().date()
    client.save()
    print(f"Updated Client ID: {client.id}, New Email: {client.email}")
    return client.id

# 3.3. Удаление
def delete_client(client_id):
    client = Client.get(Client.id == client_id)
    client.delete_instance()
    client.save()
    print(f"Deleted Client ID: {client_id}")
    return client_id

# 4. Доступ к данным через хранимую процедуру
def table_data():
    cursor = con.cursor()
    try:
        purchases = Purchase.select().limit(5)
        for purchase in purchases:
            print(purchase.id, purchase.productcount)
        cursor.execute("call increase_product_count()")
        print("Процедура выполнена")
        purchases = Purchase.select().limit(5)
        for purchase in purchases:
            print(purchase.id, purchase.productcount)
    except psycopg2.ProgrammingError as e:
        print("Ошибка:", e)
    finally:
        cursor.close()

if __name__ == "__main__":
    cmd = int(sys.argv[1])
    if cmd == 1:
        select_products()
    elif cmd == 2:
        select_purchases_with_details()
    elif cmd == 31:
        id = int(input("id: "))
        name = input("name: ")
        email = input("email: ")
        phone = input("phone: ")
        try:
            add_client(id, name, email, phone)
        except Exception as e:
            print(e)
    elif cmd == 32:
        id = int(input("id: "))
        email = input("new email: ")
        update_client(id, email)
    elif cmd == 33:
        try:
            id = int(input("id: "))
            delete_client(id)
        except:
            print("ID уже удален")
    elif cmd == 4:
        table_data()