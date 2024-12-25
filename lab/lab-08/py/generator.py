import json
import time
import os
from datetime import datetime, timedelta
from faker import Faker

class DataGenerator:
    def __init__(self):
        self.fakeRU = Faker('ru_RU')
        self.fakeEN = Faker('en_US')
        self.currentDate = datetime.now()

    # Генерация данных для магазинов
    def generateStores(self, count):
        stores = []
        for i in range(count):
            dateCreate = self.fakeRU.date_between_dates(
                date_start=self.currentDate - timedelta(days=5*365), 
                date_end=self.currentDate
            )
            stores.append({
                "name": self.fakeEN.word().capitalize() + self.fakeEN.word(),
                "email": self.fakeRU.email(),
                "url": self.fakeRU.url(),
                "datecreate": str(dateCreate),
                "datechange": str(self.fakeRU.date_between_dates(
                    date_start=dateCreate, 
                    date_end=self.currentDate
                ))
            })
        return stores

# Функция для получения количества файлов в папке data
def get_file_count(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
    return len([name for name in os.listdir(directory) if os.path.isfile(os.path.join(directory, name))])


directory = os.path.join(os.getcwd(), 'data')
file_id = get_file_count(directory) + 1 

# Функция для создания JSON файла
def create_json_file(data_generator, count):
    global directory
    global file_id

    # Имя таблицы
    table_name = "store"
    file_id_str = str(file_id)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{'0' * (4 - len(file_id_str)) + file_id_str}_{table_name}_{timestamp}.json"
    file_path = os.path.join(directory, filename)

    data = data_generator.generateStores(count)
    
    # Записываем данные в JSON файл
    with open(file_path, mode='w') as file:
        json.dump(data, file, indent=4)

    file_id += 1

    print(f"JSON file created: {file_path}")

def run_every_5_minutes(data_generator, count):

    while True:
        create_json_file(data_generator, count)
        time.sleep(30)  # Пауза в 5 минут (300 секунд)

if __name__ == "__main__":
    generator = DataGenerator()
    run_every_5_minutes(generator, 10)  # Генерируем данные для 10 магазинов каждые 5 минут

