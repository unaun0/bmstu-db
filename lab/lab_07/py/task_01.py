import json
import sys
from py_linq import Enumerable
from datetime import datetime

# Открываем файл с JSON-данными
with open('json/manufacturer.json', 'r', encoding='utf-8') as file:
    manufacturers = []
    
    # Читаем файл построчно
    for line in file:
        # Преобразуем каждую строку в JSON объект
        try:
            line 
            manufacturer = json.loads(line.strip())
            manufacturers.append(manufacturer)
        except json.JSONDecodeError as e:
            print(f"Ошибка декодирования JSON на строке: {line.strip()} - {e}")

# Преобразование данных в список объектов
manufacturers_data = Enumerable([{
    "id": item["id"],
    "name": item["name"],
    "email": item["email"],
    "URL": item["url"],
    "dateCreate": datetime.strptime(item["dateCreate"], '%Y-%m-%d').date(),
    "dateChange": datetime.strptime(item["dateChange"], '%Y-%m-%d').date()
} for item in manufacturers])

def q1():
    # Запрос, который выбирает все поля для каждого производителя
    query1 = manufacturers_data.select(lambda x: x)

    for manufacturer in query1:
        print(manufacturer)

def q2():
    # Выбор производителей, у которых dateCreate > 2024-01-01
    query2 = manufacturers_data.where(lambda x: x['dateCreate'] > datetime(2024, 1, 1).date())

    for manufacturer in query2:
        print(manufacturer)

def q3():
    # Сортировка производителей по дате изменения
    query3 = manufacturers_data.order_by(lambda x: x['dateChange'])

    for manufacturer in query3:
        print(manufacturer)

def q4():
    # Проверить, есть ли хотя бы один производитель с URL, содержащим "https://gk.com"
    query9 = manufacturers_data.any(lambda x: "https://gk.com/" in x['URL'])
    print(f"Есть ли производитель с 'example.com': {query9}")

def q5():
    # Подсчет количества производителей, созданных после 2024 года
    query10 = manufacturers_data.count(lambda x: x['dateCreate'] > datetime(2024, 1, 1).date())
    print(f"Количество производителей, созданных после 2024 года: {query10}")

# Проверка на количество аргументов
if len(sys.argv) == 1:
    print("Параметры не переданы.")
else:
    try:
        param = int(sys.argv[1])
        eval(f"q{param}()")
    except Exception as e:
        print(f"Error: {e}")
