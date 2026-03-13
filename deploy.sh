#!/bin/bash

# ========================================
# 🚀 Автозапуск AI-Портфолио на сервере
# ========================================

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Логирование
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# ========================================
# 📦 Установка зависимостей
# ========================================
install_dependencies() {
    log "🔧 Установка системных зависимостей..."
    
    # Обновление системы
    sudo apt update && sudo apt upgrade -y
    
    # Установка Python и Git
    sudo apt install -y python3 python3-pip python3-venv git curl wget
    
    # Установка утилит для мониторинга
    sudo apt install -y htop screen tmux
    
    log "✅ Системные зависимости установлены"
}

# ========================================
# 📁 Создание директорий
# ========================================
setup_directories() {
    log "📁 Создание рабочих директорий..."
    
    sudo mkdir -p /var/www/portfolio
    sudo mkdir -p /var/log/portfolio
    sudo mkdir -p /var/backups/portfolio
    
    # Права доступа
    sudo chown -R $USER:$USER /var/www/portfolio
    sudo chown -R $USER:$USER /var/log/portfolio
    sudo chown -R $USER:$USER /var/backups/portfolio
    
    log "✅ Директории созданы"
}

# ========================================
# 📥 Клонирование и настройка проекта
# ========================================
setup_project() {
    log "📥 Клонирование проекта..."
    
    cd /var/www/portfolio
    
    # Клонирование из GitHub
    git clone https://github.com/holmok1577-ops/portfolio-website.git .
    
    # Создание виртуального окружения
    python3 -m venv venv
    source venv/bin/activate
    
    # Установка зависимостей
    pip install -r requirements.txt
    
    log "✅ Проект настроен"
}

# ========================================
# ⚙️ Настройка переменных окружения
# ========================================
setup_environment() {
    log "⚙️ Настройка переменных окружения..."
    
    cd /var/www/portfolio
    
    # Проверка наличия .env файла
    if [ ! -f .env ]; then
        warn "⚠️  Файл .env не найден. Создаю шаблон..."
        cp .env.example .env
        
        echo ""
        warn "🔴 ВАЖНО: Отредактируйте файл .env:"
        warn "   nano /var/www/portfolio/.env"
        warn "   Добавьте ваши API ключи!"
        echo ""
    else
        log "✅ Файл .env найден"
    fi
}

# ========================================
# 🔥 Создание systemd сервисов
# ========================================
setup_systemd_services() {
    log "🔥 Создание systemd сервисов..."
    
    # Сервис для веб-приложения
    sudo tee /etc/systemd/system/portfolio-web.service > /dev/null <<EOF
[Unit]
Description=Portfolio Web Application
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/var/www/portfolio
Environment=PATH=/var/www/portfolio/venv/bin
ExecStart=/var/www/portfolio/venv/bin/python main.py
Restart=always
RestartSec=10

# Логирование
StandardOutput=append:/var/log/portfolio/web.log
StandardError=append:/var/log/portfolio/web.error.log

[Install]
WantedBy=multi-user.target
EOF

    # Сервис для Telegram бота
    sudo tee /etc/systemd/system/portfolio-telegram.service > /dev/null <<EOF
[Unit]
Description=Portfolio Telegram Bot
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/var/www/portfolio
Environment=PATH=/var/www/portfolio/venv/bin
ExecStart=/var/www/portfolio/venv/bin/python telegram_bot.py
Restart=always
RestartSec=10

# Логирование
StandardOutput=append:/var/log/portfolio/telegram.log
StandardError=append:/var/log/portfolio/telegram.error.log

[Install]
WantedBy=multi-user.target
EOF

    # Перезагрузка systemd
    sudo systemctl daemon-reload
    
    # Включение сервисов
    sudo systemctl enable portfolio-web
    sudo systemctl enable portfolio-telegram
    
    log "✅ Systemd сервисы созданы и включены"
}

# ========================================
# 🔥 Настройка брандмауэра
# ========================================
setup_firewall() {
    log "🔥 Настройка брандмауэра..."
    
    # Настройка UFW
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # Разрешение SSH
    sudo ufw allow ssh
    
    # Разрешение веб-сервера
    sudo ufw allow 8000/tcp
    
    # Включение брандмауэра
    sudo ufw --force enable
    
    log "✅ Брандмауэр настроен"
}

# ========================================
# 📊 Настройка мониторинга
# ========================================
setup_monitoring() {
    log "📊 Настройка мониторинга..."
    
    # Скрипт мониторинга
    cat > /var/www/portfolio/monitor.sh << 'EOF'
#!/bin/bash

# Мониторинг сервисов
check_service() {
    if systemctl is-active --quiet $1; then
        echo "✅ $1 работает"
    else
        echo "❌ $1 не работает. Перезапуск..."
        sudo systemctl restart $1
    fi
}

# Проверка памяти
check_memory() {
    MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
    echo "📊 Использование памяти: ${MEMORY_USAGE}%"
    
    if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
        echo "⚠️  Высокое использование памяти!"
    fi
}

# Проверка диска
check_disk() {
    DISK_USAGE=$(df /var/www/portfolio | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "💾 Использование диска: ${DISK_USAGE}%"
    
    if [ $DISK_USAGE -gt 80 ]; then
        echo "⚠️  Мало места на диске!"
    fi
}

echo "🔍 Мониторинг: $(date)"
check_service portfolio-web
check_service portfolio-telegram
check_memory
check_disk
echo "---"
EOF

    chmod +x /var/www/portfolio/monitor.sh
    
    # Cron для мониторинга (каждые 5 минут)
    (crontab -l 2>/dev/null; echo "*/5 * * * * /var/www/portfolio/monitor.sh >> /var/log/portfolio/monitor.log 2>&1") | crontab -
    
    log "✅ Мониторинг настроен"
}

# ========================================
# 🔄 Скрипт обновления
# ========================================
setup_update_script() {
    log "🔄 Создание скрипта обновления..."
    
    cat > /var/www/portfolio/update.sh << 'EOF'
#!/bin/bash

# Скрипт обновления проекта
echo "🔄 Обновление проекта..."

cd /var/www/portfolio

# Бэкап текущей версии
sudo cp -r /var/www/portfolio /var/backups/portfolio/backup-$(date +%Y%m%d-%H%M%S)

# Остановка сервисов
sudo systemctl stop portfolio-web portfolio-telegram

# Обновление из Git
git pull origin main

# Обновление зависимостей
source venv/bin/activate
pip install -r requirements.txt

# Запуск сервисов
sudo systemctl start portfolio-web portfolio-telegram

echo "✅ Обновление завершено!"
EOF

    chmod +x /var/www/portfolio/update.sh
    
    log "✅ Скрипт обновления создан"
}

# ========================================
# 🚀 Запуск сервисов
# ========================================
start_services() {
    log "🚀 Запуск сервисов..."
    
    # Запуск веб-приложения
    sudo systemctl start portfolio-web
    sleep 2
    
    # Запуск Telegram бота
    sudo systemctl start portfolio-telegram
    sleep 2
    
    # Проверка статуса
    echo ""
    info "📊 Статус сервисов:"
    sudo systemctl status portfolio-web --no-pager -l
    echo ""
    sudo systemctl status portfolio-telegram --no-pager -l
    
    log "✅ Сервисы запущены"
}

# ========================================
# 📋 Информация о развертывании
# ========================================
show_info() {
    echo ""
    log "🎉 Развертывание завершено!"
    echo ""
    info "📊 Полезные команды:"
    echo "  📱 Статус веб-сервиса:   sudo systemctl status portfolio-web"
    echo "  🤖 Статус Telegram бота: sudo systemctl status portfolio-telegram"
    echo "  📊 Мониторинг:           /var/www/portfolio/monitor.sh"
    echo "  🔄 Обновление:           /var/www/portfolio/update.sh"
    echo "  📋 Логи:                 tail -f /var/log/portfolio/web.log"
    echo ""
    info "🌐 Доступ:"
    echo "  🌍 Сайт:                http://$(curl -s ifconfig.me):8000"
    echo "  🔧 Админ-панель:         http://$(curl -s ifconfig.me):8000/admin"
    echo ""
    warn "⚠️  Не забудьте:"
    warn "   1. Настроить .env файл: nano /var/www/portfolio/.env"
    warn "   2. Добавить API ключи"
    warn "   3. Проверить брандмауэр: sudo ufw status"
    echo ""
}

# ========================================
# 🎯 Главная функция
# ========================================
main() {
    log "🚀 Начало развертывания AI-Портфолио..."
    
    # Проверка root прав
    if [ "$EUID" -ne 0 ]; then
        error "❌ Запустите скрипт с sudo: sudo ./deploy.sh"
        exit 1
    fi
    
    # Выполнение всех шагов
    install_dependencies
    setup_directories
    setup_project
    setup_environment
    setup_systemd_services
    setup_firewall
    setup_monitoring
    setup_update_script
    start_services
    show_info
    
    log "🎉 Готово! Ваш AI-сайт работает 24/7!"
}

# Запуск
main "$@"
