#  Подключение к Raspberry Pi по MAC-адресу

> Автоматическое нахождение IP и подключение по SSH в одном окне

##  Задача
Упростить подключение к Raspberry Pi с рабочего ПК без:
- Доступа к роутеру
- Настройки DNS
- Использования ZeroTier на ПК
- Ручного поиска IP через `arp -a`

##  Решение
PowerShell-скрипт, который:
1. Обновляет ARP-таблицу
2. Находит Raspberry Pi по MAC-адресу
3. Извлекает IP
4. Автоматически подключается по SSH в текущем окне

##  Файл: `Connect-RPi.ps1`
```powershell
# Connect-RPi.ps1
$macSearch = "b8-27-eb-87-d4-6b"
$username = "TopUserServer"
$gateway = "192.168.1.1"

Write-Host "Updating ARP table... Pinging gateway: $gateway"
Test-Connection -ComputerName $gateway -Count 2 -Quiet | Out-Null

$arpLines = arp -a | Select-String $macSearch

if ($arpLines) {
    $line = $arpLines[0].ToString().Trim()
    $parts = ($line -split '\s+') | Where-Object { $_ -ne '' }
    $ip = $parts[0]

    Write-Host "Raspberry Pi found!"
    Write-Host "IP: $ip"
    Write-Host "MAC: $macSearch"

    Write-Host "Connecting via SSH: $username@$ip..."
    ssh "$username@$ip"

    Write-Host "SSH session ended."
} else {
    Write-Host "Raspberry Pi not found in the network."
    Write-Host "Check:"
    Write-Host "  - Is the Pi powered on?"
    Write-Host "  - Is it connected via cable?"
    Write-Host "  - MAC address: b8:27:eb:87:d4:6b"
}

## Как использовать

1. Сохранить скрипт как Connect-RPi.ps1 на рабочем столе
2. Разрешить выполнение скриптов в PowerShell (один раз)
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
3. Запустить файл Connect-RPi.ps1
