# ========================================
# 🚀 Инструкция по развертыванию на сервере
# ========================================

## 📋 Подготовка сервера

После покупки сервера выполните следующие шаги:

### 1. 🔑 Подключение к серверу
```bash
ssh root@IP_АДРЕС_СЕРВЕРА
```

### 2. 🚀 Быстрый запуск (рекомендуется)
```bash
# Скачивание и запуск основного скрипта
wget https://raw.githubusercontent.com/holmok1577-ops/portfolio-website/main/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

### 3. ⚡ Очень быстрый запуск (для теста)
```bash
wget https://raw.githubusercontent.com/holmok1577-ops/portfolio-website/main/quick-start.sh
chmod +x quick-start.sh
./quick-start.sh
```

## 🐳 Docker развертывание (альтернатива)

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Клонирование проекта
git clone https://github.com/holmok1577-ops/portfolio-website.git
cd portfolio-website

# Запуск через Docker Compose
docker-compose up -d
```

## ⚙️ Настройка после развертывания

### 1. 🔧 Настройка .env файла
```bash
nano .env
```

Добавьте ваши ключи:
```env
OPENAI_API_KEY=sk-your-openai-key
PROXY_API_KEY=your-proxy-key
TELEGRAM_BOT_TOKEN=your-telegram-token
TELEGRAM_CHAT_ID=your-chat-id
```

### 2. 🚀 Запуск сервисов
```bash
sudo systemctl start portfolio-web
sudo systemctl start portfolio-telegram
```

### 3. 📊 Проверка статуса
```bash
sudo systemctl status portfolio-web
sudo systemctl status portfolio-telegram
```

## 🌐 Доступ к приложению

- **Сайт**: `http://IP_СЕРВЕРА:8000`
- **Админ-панель**: `http://IP_СЕРВЕРА:8000/admin`
- **Пароль по умолчанию**: `admin123`

## 📋 Полезные команды

### Управление сервисами:
```bash
# Перезапуск
sudo systemctl restart portfolio-web
sudo systemctl restart portfolio-telegram

# Остановка
sudo systemctl stop portfolio-web
sudo systemctl stop portfolio-telegram

# Логи
tail -f /var/log/portfolio/web.log
tail -f /var/log/portfolio/telegram.log
```

### Обновление:
```bash
/var/www/portfolio/update.sh
```

### Мониторинг:
```bash
/var/www/portfolio/monitor.sh
```

## 🔒 Безопасность

### 1. Настройка брандмауэра
```bash
sudo ufw status
sudo ufw allow 8000
sudo ufw enable
```

### 2. Смена пароля админ-панели
- Зайдите в `/admin`
- Перейдите в "Система" → "Пароль"
- Измените пароль

## 🚨 Возможные проблемы

### Проблема: Сервисы не запускаются
```bash
# Проверка логов
sudo journalctl -u portfolio-web -f
sudo journalctl -u portfolio-telegram -f

# Ручной запуск
cd /var/www/portfolio
source venv/bin/activate
python main.py
```

### Проблема: Нет доступа к сайту
```bash
# Проверка порта
sudo netstat -tlnp | grep 8000

# Проверка брандмауэра
sudo ufw status
```

### Проблема: Telegram бот не работает
```bash
# Проверка токена
curl https://api.telegram.org/botYOUR_TOKEN/getMe
```

## 📊 Мониторинг ресурсов

### Проверка нагрузки:
```bash
# Память и CPU
htop

# Диск
df -h

# Процессы
ps aux | grep python
```

## 🔄 Автоматический перезапуск

Сервисы настроены на автоматический перезапуск при сбоях:
- `Restart=always` в systemd
- `restart: unless-stopped` в Docker

## 📞 Поддержка

Если возникнут проблемы:
1. Проверьте логи
2. Проверьте .env файл
3. Перезапустите сервисы
4. Обновите проект

## 🎉 Готово!

После выполнения этих шагов ваш AI-сайт будет работать 24/7 на сервере! 🚀
