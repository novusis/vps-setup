#!/bin/bash

set -e  # Останавливаем скрипт при ошибке

# Проверка запуска от root
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Пожалуйста, запустите скрипт с правами root: sudo $0"
  exit 1
fi

# Проверка операционной системы
if ! command -v apt &> /dev/null; then
    echo "❌ Этот скрипт предназначен для систем с apt (Ubuntu/Debian)"
    exit 1
fi

echo "🔄 Обновление системы..."
apt update && apt upgrade -y

echo "📦 Установка Git..."
apt install git -y

echo "🛡 Установка и настройка UFW..."
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable
ufw status verbose

echo "🛡 Установка и настройка fail2ban..."
apt install fail2ban -y

echo "⚙️ Создание /etc/fail2ban/jail.d/sshd.local..."
mkdir -p /etc/fail2ban/jail.d
cat <<EOF > /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = %(sshd_log)s
maxretry = 3
bantime = 12h
findtime = 10m
EOF

systemctl restart fail2ban
# Проверка статуса службы
if systemctl is-active --quiet fail2ban; then
    echo "✅ fail2ban успешно запущен"
    fail2ban-client status
    fail2ban-client status sshd
else
    echo "❌ Ошибка: fail2ban не запущен"
    journalctl -u fail2ban --no-pager -n 20
fi

echo "🐳 Установка Docker..."
apt install -y ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker --version

echo "🔀 Созание swap 1.5 гб ..."
fallocate -l 1.5G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab


echo "✅ Настройка завершена успешно."
echo "[0.0.2]"
echo "📋 Установленные компоненты:"
echo "   - Git: $(git --version)"
echo "   - UFW: активен"
echo "   - Fail2ban: активен"
echo "   - Docker: $(docker --version)"
echo "   - Swap 1.5 гб"
echo ""
echo "🔒 Рекомендации по безопасности:"
echo "   - Измените стандартный SSH порт"
echo "   - Создайте нового пользователя вместо использования root"
echo "   - Настройте SSH ключи для входа"