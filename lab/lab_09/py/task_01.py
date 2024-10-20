import psycopg2
import redis
from config import *
import json

conn = psycopg2.connect(
    dbname=DB_NAME, 
    user=DB_USER, 
    password=DB_PASS, 
    host=DB_HOST, 
    port=DB_PORT
)
cursor = conn.cursor()

r = redis.Redis(host='localhost', port=6379, db=0)

def get_top_products():
    top_products = r.get('top_products')
    if top_products:
        print("Данные из кэша.")
        return json.loads(top_products)
    print('Запрос к БД.')
    query = '''
        SELECT p.productid, pr.name, SUM(p.productCount) AS totalsold
        FROM Purchase p
        JOIN Product pr ON p.productid = pr.id
        GROUP BY p.productid, pr.name
        ORDER BY totalsold DESC
        LIMIT 10;
    '''
    cursor.execute(query)
    top_products = cursor.fetchall()
    r.setex('top_products', 60, json.dumps(top_products))

    return top_products

print(get_top_products())
cursor.close()
conn.close()
