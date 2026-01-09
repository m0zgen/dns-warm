#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Collect & Merge domains data

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
# -------------------------------------------------------------------------------------------\

# Настройки путей
COLLECTED_DIR="./collected_roots"  # ansible collected
EXISTING_WARM="./warm.txt"        # final
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