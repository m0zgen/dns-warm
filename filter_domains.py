import re

INPUT_FILE = 'warm.txt'
OUTPUT_FILE = 'cleaned.txt'

# Дополнил список "дешевых" и мусорных TLD
BAD_TLDS = {
    '.xyz', '.pro', '.cn', '.vip', '.click', '.gay', '.cc', '.link', 
    '.cfd', '.icu', '.top', '.faker', '.hota', '.home', '.lan', 
    '.shop', '.la', '.club', '.work', '.info'
}

def is_dga_aggressive(name):
    name = name.lower()
    length = len(name)
    
    # 1. Детектор "Миксов" (b2m7n, b3b9c, kfrh7)
    # Если в коротком имени (до 7 символов) больше одной цифры
    digits_count = sum(c.isdigit() for c in name)
    if length <= 7 and digits_count >= 2:
        return True

    # 2. Слишком много цифр в начале (типа 35meigui)
    if re.match(r'^\d{2,}', name):
        return True

    # 3. Проверка на "согласные подряд" (непроизносимость)
    vowels = "aeiouy"
    consonants_series = 0
    for char in name:
        if char.isalpha() and char not in vowels:
            consonants_series += 1
            if consonants_series >= 4:
                return True
        else:
            consonants_series = 0

    # 4. Подозрительные дефисы и короткие части (a-qsqs)
    if '-' in name:
        parts = name.split('-')
        if any(len(p) <= 2 for p in parts) and length > 4:
            return True

    # 5. Повторы символов (aaaa, hhhh)
    for char in set(name):
        if name.count(char) >= 4 and char != 'e':
            return True

    # 6. Общая плотность цифр для средних имен
    if length > 7 and digits_count > length * 0.3:
        return True

    return False

def is_suspicious(domain):
    domain = domain.lower().strip()
    if not domain or '.' not in domain or '_' in domain:
        return True
    
    parts = domain.split('.')
    name = parts[0]
    tld = '.' + parts[-1]

    # Фильтр TLD
    if tld in BAD_TLDS:
        return True

    # Белые исключения (чтобы не удалить полезное)
    whitelist = ['3gpp', '3p']
    if any(word in name for word in whitelist):
        return False

    # Агрессивный DGA фильтр
    if is_dga_aggressive(name):
        return True

    return False

# Обработка
try:
    with open(INPUT_FILE, 'r', encoding='utf-8') as f_in, \
         open(OUTPUT_FILE, 'w', encoding='utf-8') as f_out:
        
        count_in = 0
        count_out = 0
        for line in f_in:
            count_in += 1
            domain = line.strip()
            if not is_suspicious(domain):
                f_out.write(domain + '\n')
                count_out += 1
                
    print(f"--- Глубокая чистка завершена ---")
    print(f"Удалено: {count_in - count_out} объектов")
    print(f"Осталось: {count_out}")

except FileNotFoundError:
    print(f"Файл {INPUT_FILE} не найден.")