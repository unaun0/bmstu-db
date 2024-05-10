#!/bin/bash

# Устанавливаем путь к папке, которую нужно удалить
folderPath="$(pwd)/tables"

# Проверяем, существует ли папка
if [ -d "$folderPath" ]; then
    # Удаляем папку
    rm -r "$folderPath"
fi