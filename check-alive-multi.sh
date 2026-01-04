#!/bin/bash
INPUT="warm.txt"
# Список резолверов для сравнения
RESOLVERS=("9.9.9.9" "1.1.1.2" "77.88.8.88" "185.228.168.9")

check_dns() {
    domain=$1
    resolver=$2
    # Пробуем резолвить
    res=$(dig +short +timeout=1 +tries=1 @$resolver $domain)
    if [[ "$res" == "0.0.0.0" ]]; then
        echo "[BLOCKED] $resolver | $domain"
        echo $domain >> nxdomains.log
    fi
}

export -f check_dns

# Запускаем в 10 потоков
for res in "${RESOLVERS[@]}"; do
    echo "--- Checking via $res ---"
    cat $INPUT | xargs -P 10 -I {} bash -c "check_dns {} $res"
done