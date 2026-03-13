# ========================================
# 🚀 Dockerfile для AI-Портфолио
# ========================================

FROM python:3.9-slim

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Рабочая директория
WORKDIR /app

# Клонирование проекта
RUN git clone https://github.com/holmok1577-ops/portfolio-website.git .

# Виртуальное окружение и зависимости
RUN python3 -m venv venv
RUN . venv/bin/activate && pip install -r requirements.txt

# Создание необходимых директорий
RUN mkdir -p logs data

# Копирование .env.example если .env не существует
COPY .env.example .env

# Открытие портов
EXPOSE 8000

# Запуск приложения
CMD [". venv/bin/activate", "&&", "python", "main.py"]
