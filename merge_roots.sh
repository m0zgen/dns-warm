#!/bin/bash

# Настройки путей
COLLECTED_DIR="./collected_roots"  # папка, куда ansible сложил файлы
EXISTING_WARM="./warm.txt"        # ваш текущий файл
TEMP_FILE="combined_temp.txt"

echo "Начинаю объединение списков доменов..."

# 1. Собираем всё в одну кучу:
# - читаем все скачанные .txt
# - читаем старый warm.txt (если он существует)
# - удаляем пустые строки
# - сортируем и оставляем только уникальные
cat $COLLECTED_DIR/*.txt $EXISTING_WARM 2>/dev/null | \
    sed '/^$/d' | \
    sort -u > $TEMP_FILE

# 2. Считаем, сколько было и сколько стало (для статистики)
OLD_COUNT=$([ -f "$EXISTING_WARM" ] && wc -l < "$EXISTING_WARM" || echo 0)
NEW_COUNT=$(wc -l < $TEMP_FILE)

# 3. Заменяем старый файл новым
mv $TEMP_FILE $EXISTING_WARM

echo "Готово!"
echo "Было доменов: $OLD_COUNT"
echo "Стало после объединения: $NEW_COUNT"
echo "Обновленный список сохранен в: $EXISTING_WARM"