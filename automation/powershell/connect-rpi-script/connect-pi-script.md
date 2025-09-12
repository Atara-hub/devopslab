
1. Создайте скрипт-обёртку:
   sudo nano /home/piuser/.pi_welcome.sh

2. Вставьте содержимое (пример):

   #!/bin/bash
   echo ""
   echo "=== Post-SSH menu ==="
   echo "1) Connect to admin server (10.20.30.40)"
   echo "2) Exit to Pi shell"
   echo "====================="
   read -p "Select (1-2): " choice
   case $choice in
     1) ssh adminuser@10.20.30.40 ;;
     2) exec bash ;;
     *) echo "Unknown choice" ;;
   esac
   exec bash

3. Сделайте файл исполняемым:
   chmod +x /home/piuser/.pi_welcome.sh

4. Добавьте вызов в конец ~/.bash_profile (или ~/.profile):
   [[ -f ~/.pi_welcome.sh ]] && . ~/.pi_welcome.sh

Теперь каждый логин по SSH завершится показом меню.  
Команда exit закроет только внутренний скрипт, а шелл останется активным до следующего exit.
