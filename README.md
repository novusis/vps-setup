# vps-setup

_git, ufw, fail2ban, docker_


Для Ubuntu/Debian

## 🔥 4. Настройка стандартного фаервола (UFW)

### Установка и включение:

```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Разрешить только SSH, HTTP/HTTPS:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
```

Включить фаервол:

```bash
sudo ufw enable
```

Проверить статус:

```bash
sudo ufw status verbose
```

## 🛡 3. Установка и настройка fail2ban

### Установка:

```bash
sudo apt update
sudo apt install fail2ban -y
```

### Создание локального конфига:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.loca
```

### Изменение параметров (рекомендуемые значеия):

Открой:

```bash
sudo nano /etc/fail2ban/jail.local
```

Ищи секцию `[sshd]` и установи:

```
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = %(sshd_log)s
maxretry = 3
bantime = 12h
findtime = 10m

```

🔄 Перезапуск:

```bash
sudo systemctl restart fail2ban
```

Проверка:

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### 📦 Установка Git

```bash
sudo apt install git -y
```

### 🐳 Установка Docker:

```bash
apt update && apt upgrade -y
apt install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Проверь:

```bash
docker --version
```