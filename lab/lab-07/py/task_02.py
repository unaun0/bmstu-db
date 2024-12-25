import json
import psycopg2
import sys
from py_linq import Enumerable
from datetime import datetime
from config import DB_HOST, DB_PASS, DB_NAME, DB_PORT, DB_USER

# Подключение к базе данных PostgreSQL
def fetch_data_from_db():
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT
    )
    cursor = conn.cursor()

    # Выполнение запроса SELECT для извлечения данных
    cursor.execute("SELECT id, name, email, url, datecreate, datechange FROM Manufacturer")
    records = cursor.fetchall()

    # Преобразование данных в список словарей
    manufacturers = []
    for record in records:
        manufacturers.append({
            "id": record[0],
            "name": record[1],
            "email": record[2],
            "url": record[3],
            "dateCreate": record[4].strftime('%Y-%m-%d'),
            "dateChange": record[5].strftime('%Y-%m-%d')
        })

    # Закрытие соединения с базой данных
    cursor.close()
    conn.close()

    return manufacturers

# Запись данных в JSON файл
def write_to_json(manufacturers, filename='json/manufacturer.json'):
    with open(filename, 'w', encoding='utf-8') as file:
        for manufacturer in manufacturers:
            file.write(json.dumps(manufacturer, ensure_ascii=False) + '\n')

# Чтение данных из JSON файла
def read_json(filename='json/manufacturer.json'):
    manufacturers = []
    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            manufacturers.append(json.loads(line.strip()))
    return manufacturers

# Обновление JSON файла (обновляем поле email для определенного производителя)
def update_json(manufacturer_id, new_email, filename='json/manufacturer.json'):
    manufacturers = read_json(filename)
    for manufacturer in manufacturers:
        if manufacturer["id"] == manufacturer_id:
            manufacturer["email"] = new_email
            break
    
    # Запись обновленных данных обратно в файл
    write_to_json(manufacturers, filename)

# Добавление новой записи в JSON файл
def add_to_json(new_manufacturer, filename='json/manufacturer.json'):
    manufacturers = read_json(filename)
    manufacturers.append(new_manufacturer)

    # Запись обновленных данных обратно в файл
    write_to_json(manufacturers, filename)

# Реализуем три запроса на JSON
def linq_to_json(cmd):

    # 1. Чтение данных из JSON
    if cmd == 1:
        manufacturers_data = Enumerable(read_json())
        print("Все данные из JSON файла:")
        for manufacturer in manufacturers_data.select(lambda x: x):
            print(manufacturer)

    # 2. Обновление данных в JSON (обновим email для производителя)
    if cmd == 2:
        id = int(input("ID: "))
        email = input("new email: ")
        update_json(id, email)
        print("\nДанные после обновления email для производителя с id=2:")
        manufacturers_data = Enumerable(read_json())
        q = manufacturers_data.where(lambda x: x['id'] == id)
        for elem in q:
            print(elem)

    # 3. Добавление новой записи в JSON
    if cmd == 3:
        manufacturers_data = Enumerable(read_json())
        new_id = len(manufacturers_data) + 1
        new_manufacturer = {
            "id": new_id,
            "name": input("name: "),
            "email": input("email: "),
            "url": input("url: "),
            "dateCreate": datetime.now().strftime('%Y-%m-%d'),
            "dateChange": datetime.now().strftime('%Y-%m-%d')
        }
        add_to_json(new_manufacturer)
        print("\nДанные после добавления нового производителя:")
        manufacturers_data = Enumerable(read_json())
        q = manufacturers_data.where(lambda x: x['id'] == new_id)
        for elem in q:
            print(elem)

if __name__ == "__main__":
    manufacturers_from_db = fetch_data_from_db()
    write_to_json(manufacturers_from_db)

    linq_to_json(int(sys.argv[1]))
