# Скрипт для создания отчета в файле system_report.txt

## Создание

1. Создается папка (system_report)

2. Создается файл скрипта в формате sh (nano system_report/system_report.sh)

3. Скрипт внутри:
!/bin/bash

echo "=== Отчёт о системе (date) ==="  system_report.txt
echo ""  system_report.txt

echo " Пользователи в системе:"  system_report.txt
cut -d: -f1 /etc/passwd  sort  system_report.txt
echo ""  system_report.txt

echo " Топ-5 процессов по CPU:"  system_report.txt
ps aux --sort=-%cpu  head -6  system_report.txt
echo ""  system_report.txt

echo " Последние 5 попыток входа:"  system_report.txt
tail -5 /var/log/auth.log  system_report.txt
echo ""  system_report.txt

echo " Свободное место:"  system_report.txt
df -h  system_report.txt
echo ""  system_report.txt

echo "  Показания датчиков:"  system_report.txt
sensors 2/dev/null  system_report.txt
echo ""  system_report.txt

echo " Отчёт успешно сгенерирован: system_report.txt"

4. Делем файл исполняемым (chmod +x system_report.sh)

5. Запуск (./system_report.sh)

6. Просмотр результата (cat system_report.txt)
