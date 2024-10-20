import psycopg2
import redis
import time
import json
from datetime import datetime
import random
from threading import Thread, Lock
import matplotlib.pyplot as plt
import os
from config import *

output_dir = "grhs"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

conn = psycopg2.connect(
    dbname=DB_NAME, 
    user=DB_USER, 
    password=DB_PASS, 
    host=DB_HOST, 
    port=DB_PORT
)
cursor = conn.cursor()
flag = True

r = redis.Redis(host='localhost', port=6379, db=0)

cache_durations = []
db_durations = []

db_lock = Lock()

def get_top_products_from_db():
    cursor.execute("""
            SELECT 
                p.name, 
                SUM(pr.productCount) AS total_sales
            FROM 
                Purchase pr
            JOIN 
                Product p ON pr.productID = p.id
            GROUP BY 
                p.name
            ORDER BY 
                total_sales DESC
            LIMIT 10;
    """)
    try:
        return cursor.fetchall()
    except:
        return None

def cache_top_products():
    top_products = get_top_products_from_db()
    r.setex('top_products', 1800, json.dumps(top_products))

def get_top_products_from_cache():
    global flag
    cached_data = r.get('top_products')

    if cached_data and flag:
        return json.loads(cached_data)
    else:
        flag = True
        cache_top_products()
        return get_top_products_from_cache()

def add_random_purchase():
    global flag
    cursor.execute("SELECT COALESCE(MAX(id), 0) + 1 FROM Purchase")
    newID = cursor.fetchone()[0]
    product_count = random.randint(1, 5)
    now = datetime.now()
    cursor.execute("""
            INSERT INTO Purchase (id, storeID, clientID, productID, productCount, status, dateCreate, dateChange)
            VALUES (%s, 1, 1, 1, %s, 'В обработке', %s, %s)
    """, (newID, product_count, now, now))
    conn.commit()

    flag = False
    
def delete_random_purchase():
    while True:
        random_id = random.randint(1, 1000)
        cursor.execute("SELECT COUNT(*) FROM Purchase WHERE id = %s", (random_id,))
        exists = cursor.fetchone()[0] > 0
        if exists:
            cursor.execute("DELETE FROM Purchase WHERE id = %s", (random_id,))
            conn.commit()
            global flag
            flag = False
            break

def update_random_purchase():
    prod_count = random.randint(1, 1000) 
    while True:
        random_id = random.randint(1, 1000)
        cursor.execute("SELECT COUNT(*) FROM Purchase WHERE id = %s", (random_id,))
        exists = cursor.fetchone()[0] > 0
        if exists:
            cursor.execute("UPDATE Purchase SET ProductCount = %s WHERE id = %s", (prod_count, random_id))
            conn.commit()
            global flag
            flag = False
            break

def cache_query():
    for _ in range(30):
        with db_lock:
            start_time = time.time()
            get_top_products_from_cache()
            duration = time.time() - start_time
            cache_durations.append(duration)
        time.sleep(5)

def db_query():
    for _ in range(30):
        with db_lock:
            start_time = time.time()
            get_top_products_from_db()
            duration = time.time() - start_time
            db_durations.append(duration)
        time.sleep(5)

def data_insert():
    for _ in range(15):
        with db_lock:
            add_random_purchase()
        time.sleep(10)

def data_delete():
    for _ in range(15):
        with db_lock:
            delete_random_purchase()
        time.sleep(10)

def data_update():
    for _ in range(15):
        with db_lock:
            update_random_purchase()
        time.sleep(10)

def graph_insert():
    global cache_durations, db_durations, flag
    cache_durations, db_durations = [], []
    flag = True

    cache_thread = Thread(target=cache_query)
    db_thread = Thread(target=db_query)
    insert_thread = Thread(target=data_insert)

    cache_thread.start()
    db_thread.start()
    insert_thread.start()

    cache_thread.join()
    db_thread.join()
    insert_thread.join()

    avg_cache_duration = sum(cache_durations) / len(cache_durations)
    avg_db_duration = sum(db_durations) / len(db_durations)

    print("Среднее время выполнения запроса к кэшу:", avg_cache_duration)
    print("Среднее время выполнения запроса к базе данных:", avg_db_duration)

    labels = ['Кэш', 'БД']
    avg_durations = [avg_cache_duration, avg_db_duration]

    plt.figure(figsize=(8, 6))
    plt.bar(labels, avg_durations, color=['blue', 'green'], edgecolor='black')

    plt.title('Среднее время выполнения запросов при вставке данных в БД')
    plt.ylabel('Время (сек)')
    plt.xlabel('Тип запроса')

    for i, value in enumerate(avg_durations):
        plt.text(i, value + 0.01, f'{value:.6f}', ha='center', va='bottom')

    plt.savefig(os.path.join(output_dir, 'insert.png'))
    plt.close()

    print(f"График сохранён в папку {output_dir} под именем 'insert.png'")

def graph_just():
    global cache_durations, db_durations, flag
    cache_durations, db_durations = [], []
    flag = True

    cache_thread = Thread(target=cache_query)
    db_thread = Thread(target=db_query)

    cache_thread.start()
    db_thread.start()

    cache_thread.join()
    db_thread.join()

    avg_cache_duration = sum(cache_durations) / len(cache_durations)
    avg_db_duration = sum(db_durations) / len(db_durations)

    print("Среднее время выполнения запроса к кэшу:", avg_cache_duration)
    print("Среднее время выполнения запроса к базе данных:", avg_db_duration)

    labels = ['Кэш', 'БД']
    avg_durations = [avg_cache_duration, avg_db_duration]

    plt.figure(figsize=(8, 6))
    plt.bar(labels, avg_durations, color=['blue', 'green'], edgecolor='black')

    plt.title('Среднее время выполнения запросов')
    plt.ylabel('Время (сек)')
    plt.xlabel('Тип запроса')

    for i, value in enumerate(avg_durations):
        plt.text(i, value + 0.01, f'{value:.6f}', ha='center', va='bottom')

    plt.savefig(os.path.join(output_dir, 'just.png'))
    plt.close()

    print(f"График сохранён в папку {output_dir} под именем 'just.png'")

def graph_delete():
    global cache_durations, db_durations, flag
    cache_durations, db_durations = [], []
    flag = True

    cache_thread = Thread(target=cache_query)
    db_thread = Thread(target=db_query)
    delete_thread = Thread(target=data_delete)

    cache_thread.start()
    db_thread.start()
    delete_thread.start()

    cache_thread.join()
    db_thread.join()
    delete_thread.join()

    avg_cache_duration = sum(cache_durations) / len(cache_durations)
    avg_db_duration = sum(db_durations) / len(db_durations)

    print("Среднее время выполнения запроса к кэшу:", avg_cache_duration)
    print("Среднее время выполнения запроса к базе данных:", avg_db_duration)

    labels = ['Кэш', 'БД']
    avg_durations = [avg_cache_duration, avg_db_duration]

    plt.figure(figsize=(8, 6))
    plt.bar(labels, avg_durations, color=['blue', 'green'], edgecolor='black')

    plt.title('Среднее время выполнения запросов при удалении данных в БД')
    plt.ylabel('Время (сек)')
    plt.xlabel('Тип запроса')

    for i, value in enumerate(avg_durations):
        plt.text(i, value + 0.01, f'{value:.6f}', ha='center', va='bottom')

    plt.savefig(os.path.join(output_dir, 'delete.png'))
    plt.close()

    print(f"График сохранён в папку {output_dir} под именем 'delete.png'")

def graph_update():
    global cache_durations, db_durations, flag
    cache_durations, db_durations = [], []
    flag = True

    cache_thread = Thread(target=cache_query)
    db_thread = Thread(target=db_query)
    update_thread = Thread(target=data_delete)

    cache_thread.start()
    db_thread.start()
    update_thread.start()

    cache_thread.join()
    db_thread.join()
    update_thread.join()

    avg_cache_duration = sum(cache_durations) / len(cache_durations)
    avg_db_duration = sum(db_durations) / len(db_durations)

    print("Среднее время выполнения запроса к кэшу:", avg_cache_duration)
    print("Среднее время выполнения запроса к базе данных:", avg_db_duration)

    labels = ['Кэш', 'БД']
    avg_durations = [avg_cache_duration, avg_db_duration]

    plt.figure(figsize=(8, 6))
    plt.bar(labels, avg_durations, color=['blue', 'green'], edgecolor='black')

    plt.title('Среднее время выполнения запросов при обновлении данных в БД')
    plt.ylabel('Время (сек)')
    plt.xlabel('Тип запроса')

    for i, value in enumerate(avg_durations):
        plt.text(i, value + 0.01, f'{value:.6f}', ha='center', va='bottom')

    plt.savefig(os.path.join(output_dir, 'update.png'))
    plt.close()

    print(f"График сохранён в папку {output_dir} под именем 'update.png'")

if __name__ == '__main__':
   graph_insert()
   graph_just()
   graph_delete()
   graph_update()

cursor.close()
conn.close()
