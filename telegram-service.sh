#!/bin/bash

# ========================================
# 🤖 Отдельный скрипт для Telegram бота
# ========================================

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Создание systemd сервиса для Telegram бота
create_telegram_service() {
    log "🤖 Создание сервиса для Telegram бота..."
    
    sudo tee /etc/systemd/system/portfolio-telegram.service > /dev/null <<EOF
[Unit]
Description=Portfolio Telegram Bot
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/var/www/portfolio
Environment=PATH=/var/www/portfolio/venv/bin
Environment=TELEGRAM_BOT_TOKEN=\${TELEGRAM_BOT_TOKEN}
Environment=TELEGRAM_CHAT_ID=\${TELEGRAM_CHAT_ID}
Environment=OPENAI_API_KEY=\${OPENAI_API_KEY}
Environment=PROXY_API_KEY=\${PROXY_API_KEY}
ExecStart=/var/www/portfolio/venv/bin/python telegram_bot.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/portfolio/telegram.log
StandardError=append:/var/log/portfolio/telegram.error.log

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable portfolio-telegram
    log "✅ Сервис Telegram бота создан"
}

# Запуск бота
start_telegram_bot() {
    log "🚀 Запуск Telegram бота..."
    
    # Остановка если уже работает
    sudo systemctl stop portfolio-telegram 2>/dev/null
    
    # Запуск
    sudo systemctl start portfolio-telegram
    
    # Проверка
    sleep 3
    if sudo systemctl is-active --quiet portfolio-telegram; then
        log "✅ Telegram бот запущен"
    else
        error "❌ Ошибка запуска Telegram бота"
        sudo systemctl status portfolio-telegram --no-pager
    fi
}

# Проверка работы
check_telegram() {
    log "📊 Проверка работы Telegram бота..."
    
    if sudo systemctl is-active --quiet portfolio-telegram; then
        log "✅ Бот работает"
        echo "📋 Последние логи:"
        tail -10 /var/log/portfolio/telegram.log
    else
        error "❌ Бот не работает"
        echo "📋 Логи ошибок:"
        tail -10 /var/log/portfolio/telegram.error.log
    fi
}

# Тестирование бота
test_telegram() {
    log "🧪 Тестирование Telegram бота..."
    
    # Проверка токена
    if [ -f /var/www/portfolio/.env ]; then
        source /var/www/portfolio/.env
        
        if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
            log "🔑 Токен найден, проверка..."
            curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getMe" | grep -q "ok" && log "✅ Токен рабочий" || error "❌ Токен неверный"
        else
            warn "⚠️ Токен не найден в .env"
        fi
    else
        warn "⚠️ Файл .env не найден"
    fi
}

# Главное меню
case "$1" in
    "start")
        create_telegram_service
        start_telegram_bot
        ;;
    "stop")
        sudo systemctl stop portfolio-telegram
        log "🛑 Telegram бот остановлен"
        ;;
    "restart")
        sudo systemctl restart portfolio-telegram
        log "🔄 Telegram бот перезапущен"
        ;;
    "status")
        sudo systemctl status portfolio-telegram --no-pager
        ;;
    "check")
        check_telegram
        ;;
    "test")
        test_telegram
        ;;
    "logs")
        tail -f /var/log/portfolio/telegram.log
        ;;
    *)
        echo "🤖 Управление Telegram ботом:"
        echo "  $0 start   - Запуск бота"
        echo "  $0 stop    - Остановка бота"
        echo "  $0 restart - Перезапуск бота"
        echo "  $0 status  - Статус бота"
        echo "  $0 check   - Проверка работы"
        echo "  $0 test    - Тест токена"
        echo "  $0 logs    - Просмотр логов"
        ;;
esac
