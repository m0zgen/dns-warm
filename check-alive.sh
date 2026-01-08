#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Warm.txt domain checker

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd); cd $SCRIPT_PATH

# -------------------------------------------------------------------------------------------\
DOMAIN_LIST="${1:-warm.txt}"
NXDOMAIN_LIST="nxdomains.log"

if [ ! -f "$DOMAIN_LIST" ]; then
    echo "Error: File '$DOMAIN_LIST' not found."
    exit 1
fi

> "$NXDOMAIN_LIST"

echo "Checking domains..."
echo "------------------------------"

while IFS= read -r domain || [ -n "$domain" ]; do
    # Очистка строки от пробелов и пропуск комментариев
    domain=$(echo "$domain" | xargs)
    [[ -z "$domain" || "$domain" =~ ^# ]] && continue

    # - +short: лаконичный вывод
    # - +tries=1 +time=2: чтобы скрипт не висел долго на мертвых доменах
    # - Используем Google DNS (8.8.8.8) напрямую для стабильности
    
    # Выполняем запрос и сохраняем ВЕСЬ ответ в переменную, чтобы не дергать сеть дважды
    RAW_OUTPUT=$(dig @8.8.8.8 "$domain" +tries=1 +time=2 +noall +comments)
    
    # Извлекаем RCODE: 
    # 1. Ищем строку со 'status:'
    # 2. Вырезаем все, что ДО 'status: '
    # 3. Берем первое слово (код) и удаляем из него запятую
    RCODE=$(echo "$RAW_OUTPUT" | grep "status:" | sed 's/.*status: //' | awk '{print $1}' | tr -d ',')

    # Если RCODE пустой, значит случился таймаут или нет связи
    if [ -z "$RCODE" ]; then
        echo "❓ $domain: TIMEOUT / NO CONNECTION"
        echo "$domain" >> "$NXDOMAIN_LIST"
        continue
    fi

    case "$RCODE" in
        "NOERROR")
            echo "✅ $domain: EXISTS"
            ;;
        "NXDOMAIN")
            echo "❌ $domain: NOT FOUND"
            echo "$domain" >> "$NXDOMAIN_LIST"
            ;;
        *)
            echo "⚠️ $domain: STATUS $RCODE"
            echo "$domain" >> "$NXDOMAIN_LIST"
            # Для отладки можно раскомментировать следующую строку:
            # echo "Debug: $RAW_OUTPUT" 
            ;;
    esac

done < "$DOMAIN_LIST"

echo "------------------------------"
echo "Done. Dead domains saved to $NXDOMAIN_LIST"