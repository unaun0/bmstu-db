import psycopg2
from config import DB_HOST, DB_NAME, DB_USER, DB_PASS, DB_PORT
from tabulate import tabulate
import pyfiglet

# Цветовые коды
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
MAGENTA = "\033[95m"
CYAN = "\033[96m"
RESET = "\033[0m"

class DatabaseApp:

    def __init__(self, dbname, user, password, host, port):
        """Инициализация приложения и подключение к базе данных"""

        try:
            self.conn = psycopg2.connect(
                dbname=dbname,
                user=user,
                password=password,
                host=host,
                port=port
            )
            self.cursor = self.conn.cursor()
        except Exception as e:
            print(f'Ошибка: {e}')

    def scalar_query(self):
        """1. Скалярный запрос"""

        self.cursor.execute(
            """
            SELECT ROUND(AVG(productCount), 6) 
            FROM Purchase;
            """
        )
        result = self.cursor.fetchone()
        print(f"{YELLOW}Среднее количество товаров в заказе:{RESET} {result[0]}\n")

    def join_query(self):
        """2. Выполнить запрос с несколькими соединениями (JOIN)"""

        self.cursor.execute("""
            SELECT p.id, p.clientID, c.name, c.phone 
            FROM Purchase p
            JOIN Client c ON p.clientID = c.id
            ORDER BY p.id;
        """)
        results = self.cursor.fetchall()

        headers = ["ID заказа", "ID клиента", "ФИО", "Номер телефона"]
        print('\n', tabulate(results, headers, tablefmt="simple"), '\n')

    def cte_window_query(self):
        """3. Выполнить запрос с ОТВ (CTE) и оконными функциями"""

        self.cursor.execute(
            """
            WITH ProductStats AS (
                SELECT 
                    pr.id, 
                    pr.name, 
                    MIN(p.productCount) OVER (PARTITION BY p.productID) AS minProductCount,
                    MAX(p.productCount) OVER (PARTITION BY p.productID) AS maxProductCount
                FROM 
                    Product pr
                JOIN 
                    Purchase p ON pr.id = p.productID
            )
            SELECT DISTINCT 
                id, 
                name, 
                minProductCount,
                maxProductCount
            FROM 
                ProductStats
            ORDER BY 
                id;
            """
        )
        results = self.cursor.fetchall()

        headers = ["ID продукта", "Название", "Мин. единиц в заказе", "Макс. единиц в заказе"]
        print('\n', tabulate(results, headers, tablefmt="simple"), '\n')

    def metadata_query(self):
        """4. Выполнить запрос к метаданным"""

        self.cursor.execute(
            """
            SELECT 
                table_name,
                table_schema,
                table_type
            FROM 
                information_schema.tables
            WHERE table_schema LIKE 'public';
            """
        )
        results = self.cursor.fetchall()

        headers = ["Имя объекта", "Схема", "Тип"]
        print('\n', tabulate(results, headers, tablefmt="simple"), '\n')

    def call_scalar_function(self):
        """5. Вызвать скалярную функцию"""

        self.cursor.execute(
            """
            SELECT
                id,
                total_purchase_cost(id)
            FROM Purchase
            ORDER BY id;
            """
        )
        results = self.cursor.fetchall()
        formatted_results = [
            (id_order, f"{total:,.2f}")
            for id_order, total in results
        ]
    
        headers = ["ID заказа", "Итоговая стоимость"]
        print('\n', tabulate(formatted_results, headers, tablefmt="simple"), '\n')

    def call_table_function(self):
        """6. Вызвать табличную функцию"""

        id = input(f'\n{YELLOW}Введите ID клиента: {RESET}')
        try:
            self.cursor.execute(
                f"SELECT * FROM get_purchases_by_client({id});"
            )
            results = self.cursor.fetchall()

            headers = ["ID заказа", "Название проукта", "Название магазина", "Количество", "Статус", "Дата"]
            print('\n', tabulate(results, headers, tablefmt="simple"), '\n')
        except Exception as e:
            print(f'\n{RED}ERROR: {RESET}: {e}\n')

    def call_stored_procedure(self):
        """7. Вызвать хранимую процедуру"""

        id = input(f'\n{YELLOW}Введите ID заказа: {RESET}')
        count = input(f'{YELLOW}Введите количество: {RESET}')
        try:
            self.cursor.execute(
                f'CALL update_product_count({id}, {count});'
            )
            self.conn.commit()
            print(f'\n{GREEN}INFO:{RESET} хранимая процедура выполнена.\n')
        except Exception as e:
            print(f'\n{RED}ERROR:{RESET} {e}\n')

    def call_system_function(self):
        """8. Вызвать системную функцию или процедуру"""

        self.cursor.execute("SELECT version();")
        result = self.cursor.fetchone()
        print(f"\n{YELLOW}Версия PostgreSQL{RESET}: {result[0]}\n")

    def create_table(self):
        """9. Создать таблицу"""

        self.cursor.execute("""
            DROP TABLE IF EXISTS ProductAnalog;
            CREATE TABLE ProductAnalog (
                productID INT,
                analogProductID INT,
                PRIMARY KEY (productID, analogProductID),
                FOREIGN KEY (productID) REFERENCES Product(id),
                FOREIGN KEY (analogProductID) REFERENCES Product(id)
            );
        """)
        self.conn.commit()
        print(f"\n{YELLOW}Создана таблица ProductAnalog с полями: productID, analogProductID.{RESET}\n")

    def insert_data(self):
        """10. Выполнить вставку данных"""

        pid = input(f'\n{YELLOW}Введите ID продукта: {RESET}')
        aid = input(f'{YELLOW}Введите ID продукта - аналога: {RESET}')
        try:
            self.cursor.execute(
                f'INSERT INTO ProductAnalog (productID, analogProductID) VALUES ({pid}, {aid});'
            )
            self.conn.commit()
            print(f'{GREEN}INFO:{RESET} Данные вставлены.\n')
        except Exception as e:
            print(f'\n{RED}ERROR:{RESET} {e}\n')

    def close(self):
        """Закрыть подключение"""

        self.cursor.close()
        self.conn.close()


def menu():
    app = DatabaseApp(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST,
        port=DB_PORT
    )
    
    showmenu = True
    title = pyfiglet.figlet_format("MarketDB")

    print('\n' * 2000)
    print(title)

    while True:
        if showmenu:
            print(f"\n{BLUE}Меню:{RESET}")
            print(f"{GREEN} 1.{RESET} Получить среднее количество заказанных товаров.")
            print(f"{GREEN} 2.{RESET} Получить для каждого заказа информацию о заказчике")
            print(f"{GREEN} 3.{RESET} Получить для каждого продукта информацию о мин. и макс. количестве единиц в заказе")
            print(f"{GREEN} 4.{RESET} Получить список всех объектов, которые находятся в схеме public")
            print(f"{GREEN} 5.{RESET} Получить итоговую стоимость для каждого заказа")
            print(f"{GREEN} 6.{RESET} Получить информацию о заказах клиента по ID")
            print(f"{GREEN} 7.{RESET} Обновить количество продукта в заказе по ID")
            print(f"{GREEN} 8.{RESET} Получить информацию о версии PostgreSQL")
            print(f"{GREEN} 9.{RESET} Создать таблицу для аналогов продуктов")
            print(f"{GREEN}10.{RESET} Добавить данные о продуктах - аналогах в таблицу")
            print(f"{GREEN}11.{RESET} Вывести меню")
            print(f"{RED} 0.{RESET} Выход")

            showmenu = False
        else:
            print(f"{GREEN}INFO:{RESET} Чтобы вывести меню - введите 11")
        choice = input(f"{MAGENTA}Выберите пункт меню: {RESET}")
        
        if choice == '1':
            app.scalar_query()
        elif choice == '2':
            app.join_query()
        elif choice == '3':
            app.cte_window_query()
        elif choice == '4':
            app.metadata_query()
        elif choice == '5':
            app.call_scalar_function()
        elif choice == '6':
            app.call_table_function()
        elif choice == '7':
            app.call_stored_procedure()
        elif choice == '8':
            app.call_system_function()
        elif choice == '9':
            app.create_table()
        elif choice == '10':
            app.insert_data()
        elif choice == '11':
            showmenu = True
        elif choice == '0':
            app.close()
            print("Пока - пока :3\n\n")
            break
        else:
            print("Неверный выбор, попробуйте еще раз.")

