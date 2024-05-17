#!/bin/bash

# Устанавливаем путь к папке, которую нужно удалить
tablesFolderPath="$(pwd)/tables"

# Проверяем, существует ли папка
if [ -d "$tablesFolderPath" ]; then
    # Удаляем папку
    rm -r "$tablesFolderPath"
fi

mkdir "$tablesFolderPath"

python3 py/main.py

psql -U postgres -d market -f "$(pwd)/sql/lab_1_1.sql"
psql -U postgres -d market -f "$(pwd)/sql/lab_1_2.sql"
psql -U postgres -d market -f "$(pwd)/sql/lab_1_3.sql"

rm -r "$tablesFolderPath"
rm -r "$(pwd)/py/__pycache__"

