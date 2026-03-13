#!/bin/bash

# ========================================
# 🚀 Быстрый старт для Ubuntu/CentOS сервера
# ========================================

echo "🚀 Быстрый старт AI-Портфолио"
echo "================================"

# Проверка ОС
if [ -f /etc/lsb-release ]; then
    OS="Ubuntu"
elif [ -f /etc/redhat-release ]; then
    OS="CentOS"
else
    echo "❌ Неподдерживаемая ОС"
    exit 1
fi

echo "📋 Обнаружена ОС: $OS"

# Быстрая установка
echo "🔧 Быстрая установка зависимостей..."

if [ "$OS" = "Ubuntu" ]; then
    sudo apt update && sudo apt install -y python3 python3-pip python3-venv git curl wget
elif [ "$OS" = "CentOS" ]; then
    sudo yum install -y python3 python3-pip git curl wget
fi

# Клонирование и запуск
echo "📥 Клонирование проекта..."
git clone https://github.com/holmok1577-ops/portfolio-website.git
cd portfolio-website

# Виртуальное окружение
echo "🐍 Создание виртуального окружения..."
python3 -m venv venv
source venv/bin/activate

# Установка зависимостей
echo "📦 Установка зависимостей..."
pip install -r requirements.txt

# Настройка .env
if [ ! -f .env ]; then
    echo "⚙️ Создание .env файла..."
    cp .env.example .env
    echo "🔴 ВАЖНО: Отредактируйте .env файл!"
    echo "   nano .env"
    echo "   Добавьте ваши API ключи!"
fi

# Запуск в фоне
echo "🚀 Запуск приложения..."
nohup python main.py > app.log 2>&1 &
echo $! > app.pid

echo ""
echo "✅ Готово!"
echo "🌐 Сайт доступен: http://$(curl -s ifconfig.me):8000"
echo "📋 Логи: tail -f app.log"
echo "🛑 Остановка: kill \$(cat app.pid)"
echo ""
echo "⚠️  Для полноценного развертывания используйте:"
echo "   sudo ./deploy.sh"
