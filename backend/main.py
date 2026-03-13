from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, EmailStr
from typing import List, Optional, Dict, Any
import json
import os
from datetime import datetime
import httpx

app = FastAPI(title="Станислав - Промпт-инженер API", version="1.0.0")

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # В продакшене указать конкретные домены
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Раздача статических файлов только для не-API путей
from fastapi.responses import FileResponse
import os as os_module

# Получаем абсолютный путь к директории frontend
BASE_DIR = os_module.path.dirname(os_module.path.abspath(__file__))
FRONTEND_DIR = os_module.path.join(os_module.path.dirname(BASE_DIR), "frontend")

@app.get("/")
async def serve_index():
    """Главная страница"""
    return FileResponse(os_module.path.join(FRONTEND_DIR, "index.html"))

@app.get("/{path:path}")
async def serve_static(path: str):
    """Статические файлы"""
    # API пути пропускаем
    if path.startswith("api/"):
        raise HTTPException(status_code=404, detail="Not found")
    
    file_path = os_module.path.join(FRONTEND_DIR, path)
    if os_module.path.exists(file_path) and os_module.path.isfile(file_path):
        return FileResponse(file_path)
    
    # Для SPA возвращаем index.html
    return FileResponse(os_module.path.join(FRONTEND_DIR, "index.html"))

# Модели данных
class ServiceRequest(BaseModel):
    name: str
    email: str
    phone: Optional[str] = None
    service_type: str
    message: str

class Project(BaseModel):
    id: int
    title: str
    description: str
    technology: str
    link: str
    image_url: Optional[str] = None

class ChatRequest(BaseModel):
    message: str
    model: str = "gpt-3.5-turbo"

class EmbeddingRequest(BaseModel):
    input: str
    model: str = "text-embedding-3-small"

# Временное хранилище (в продакшене использовать БД)
PROJECTS = [
    {
        "id": 1,
        "title": "Docker репозиторий",
        "description": "Коллекция Docker-образов для различных AI-решений",
        "technology": "Docker",
        "link": "https://hub.docker.com/repositories/holmok1577",
        "image_url": "/images/docker-logo.png"
    },
    {
        "id": 2,
        "title": "GitHub проекты",
        "description": "Open-source проекты и примеры кода",
        "technology": "GitHub",
        "link": "https://github.com/holmok1577-ops",
        "image_url": "/images/github-logo.png"
    }
]

@app.get("/")
async def root():
    return {"message": "API Станислава - промпт-инженера"}

@app.get("/api/projects", response_model=List[Project])
async def get_projects():
    """Получить список проектов"""
    return PROJECTS

@app.get("/api/services")
async def get_services():
    """Получить список услуг"""
    return {
        "services": [
            {
                "id": 1,
                "title": "Телеграм-боты",
                "description": "Автоматизация обработки заявок и обращений пользователей",
                "icon": "🤖"
            },
            {
                "id": 2,
                "title": "Автономные агенты",
                "description": "Умные ассистенты для выполнения рутинных задач",
                "icon": "🧠"
            },
            {
                "id": 3,
                "title": "ИИ-ассистенты",
                "description": "Виртуальные помощники для поддержки клиентов",
                "icon": "💬"
            }
        ]
    }

@app.post("/api/request")
async def create_service_request(request: ServiceRequest, background_tasks: BackgroundTasks):
    """Создать заявку на услугу"""
    
    # Сохранение заявки (в продакшене - в БД)
    request_data = {
        "id": len(PROJECTS) + 1,
        "timestamp": datetime.now().isoformat(),
        "name": request.name,
        "email": request.email,
        "phone": request.phone,
        "service_type": request.service_type,
        "message": request.message,
        "status": "new"
    }
    
    # Фоновая задача для отправки уведомления
    background_tasks.add_task(send_notification, request_data)
    
    return {
        "success": True,
        "message": "Заявка успешно отправлена! Я свяжусь с вами в ближайшее время.",
        "request_id": request_data["id"]
    }

async def send_notification(request_data: dict):
    """Фоновая задача для отправки уведомления"""
    # Здесь можно добавить логику отправки email или Telegram уведомления
    print(f"Новая заявка: {request_data}")

@app.get("/api/about")
async def get_about():
    """Получить информацию обо мне"""
    return {
        "name": "Станислав",
        "title": "Промпт-инженер",
        "description": "Создаю эффективные решения на основе технологий искусственного интеллекта. Веду проекты от идеи до финала, разрабатываю ИИ-помощников с нуля до готового продукта.",
        "guarantee": "Годовая поддержка всех проектов бесплатно — устраняю поломки в течение первого года эксплуатации.",
        "experience": "Специализируюсь на создании AI-решений для бизнеса"
    }

# AI Чат эндпоинты
@app.post("/api/chat/direct")
async def direct_chat(request: ChatRequest):
    """Прямое общение с нейросетью через прокси API"""
    
    # Здесь будет интеграция с прокси API OpenAI
    # Для демонстрации возвращаем симулированный ответ
    
    # Заглушка для API ключа - в продакшене использовать переменные окружения
    PROXY_API_KEY = os.getenv("PROXY_API_KEY", "sk-jmykkSFym23SOaHx9Syx99GTIz3cnhC6")
    PROXY_API_URL = "https://api.proxyapi.ru/openai/v1/chat/completions"
    
    # Если API ключ не установлен или это демо-ключ, возвращаем симуляцию
    if not PROXY_API_KEY or PROXY_API_KEY == "your-proxy-api-key":
        return {
            "response": f"Демонстрационный режим ответа от {request.model}:\n\nНа запрос '{request.message}' я бы ответил:\n\nЭто интересный вопрос о промпт-инжиниринге! В режиме прямого общения с нейросетью я могу предоставить гибкие и креативные ответы, используя возможности языковых моделей без ограничений базы знаний.\n\nДля полноценной работы нужен реальный API ключ прокси.",
            "model": request.model,
            "mode": "direct",
            "note": "Демонстрационный режим - нужен API ключ"
        }
    
    try:
        print(f"Отправка запроса к API: модель={request.model}, сообщение='{request.message[:50]}...'")
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                PROXY_API_URL,
                headers={
                    "Authorization": f"Bearer {PROXY_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": request.model,
                    "messages": [
                        {
                            "role": "system",
                            "content": "Ты - профессиональный промпт-инженер Станислав. Ты эксперт в области искусственного интеллекта, больших языковых моделей (LLM), промпт-инжиниринга и RAG систем. Твои задачи:\n\n1. Отвечать на вопросы о промпт-инжиниринге и AI технологиях\n2. Помогать с оптимизацией промптов\n3. Объяснять концепции LLM и нейросетей\n4. Консультировать по созданию AI-ассистентов\n5. Давать практические советы по внедрению AI\n\nОтвечай экспертно, но доступно. Используй примеры и структурированные ответы. Будь дружелюбен и профессионален."
                        },
                        {
                            "role": "user",
                            "content": request.message
                        }
                    ],
                    "max_tokens": 1000,
                    "temperature": 0.7
                }
            )
            
            print(f"Статус ответа API: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                return {
                    "response": data["choices"][0]["message"]["content"],
                    "model": request.model,
                    "mode": "direct"
                }
            else:
                error_text = response.text
                print(f"Ошибка API: {error_text}")
                return {
                    "response": f"Ошибка API ({response.status_code}): Не удалось получить ответ от нейросети. Проверьте API ключ и подключение.",
                    "model": request.model,
                    "mode": "direct",
                    "error": f"HTTP {response.status_code}"
                }
                
    except httpx.TimeoutException:
        return {
            "response": "Тайм-аут запроса к нейросети. Попробуйте еще раз.",
            "model": request.model,
            "mode": "direct",
            "error": "timeout"
        }
    except httpx.ConnectError:
        return {
            "response": "Не удалось подключиться к API нейросети. Проверьте интернет-соединение.",
            "model": request.model,
            "mode": "direct",
            "error": "connection_error"
        }
    except Exception as e:
        print(f"Непредвиденная ошибка: {str(e)}")
        return {
            "response": f"Произошла ошибка при запросе к нейросети: {str(e)}",
            "model": request.model,
            "mode": "direct",
            "error": str(e)
        }

# Административные эндпоинты
@app.get("/api/admin/profile")
async def get_admin_profile():
    """Получить профиль администратора"""
    # В реальном приложении здесь будет проверка авторизации
    return {
        "name": "Станислав",
        "title": "Промпт-инженер",
        "bio": "Создаю эффективные решения на основе технологий искусственного интеллекта. Веду проекты от идеи до финала, разрабатываю ИИ-помощников с нуля до готового продукта.",
        "email": "email@example.com",
        "telegram": "@username",
        "phone": "+79991234567"
    }

@app.get("/api/admin/projects")
async def get_admin_projects():
    """Получить проекты администратора"""
    # В реальном приложении здесь будет проверка авторизации
    return PROJECTS

@app.get("/api/admin/knowledge")
async def get_admin_knowledge():
    """Получить базу знаний администратора"""
    # В реальном приложении здесь будет проверка авторизации
    return {
        "knowledge_base": [
            {
                "id": 1,
                "title": "Промпт-инжиниринг",
                "content": "Промпт-инжиниринг - это искусство формулирования эффективных запросов к языковым моделям. Включает техники zero-shot, few-shot, chain-of-thought. Ключевые принципы: ясность, конкретика, контекст, ролевые инструкции.",
                "category": "basic"
            },
            {
                "id": 2,
                "title": "LLM модели",
                "content": "Большие языковые модели (LLM) - это нейронные сети, обученные на больших объемах текста. Понимание их ограничений и сильных сторон ключено для эффективного использования. Основные модели: GPT-3.5, GPT-4, Claude, Llama.",
                "category": "models"
            },
            {
                "id": 3,
                "title": "RAG системы",
                "content": "Retrieval-Augmented Generation (RAG) комбинирует поиск релевантной информации с генерацией ответа, повышая точность и актуальность. Компоненты: база знаний, векторные эмбеддинги, семантический поиск, генерация ответа.",
                "category": "advanced"
            },
            {
                "id": 4,
                "title": "Векторные эмбеддинги",
                "content": "Эмбеддинги - это векторные представления текста, позволяющие измерять семантическую близость между текстами. Модели: text-embedding-3-small (1536 измерений), text-embedding-3-large (3072 измерений). Применение: поиск, кластеризация, рекомендации.",
                "category": "advanced"
            },
            {
                "id": 5,
                "title": "Бизнес-применение",
                "content": "AI технологии в бизнесе: автоматизация поддержки, анализ данных, создание контента, персонализация предложений, оптимизация бизнес-процессов. ROI от внедрения AI: экономия времени, снижение издержек, повышение качества.",
                "category": "business"
            }
        ]
    }

@app.post("/api/embeddings")
async def create_embeddings(request: EmbeddingRequest):
    """Создание векторных эмбеддингов через прокси API"""
    
    PROXY_API_KEY = os.getenv("PROXY_API_KEY", "your-proxy-api-key")
    PROXY_API_URL = "https://api.proxyapi.ru/openai/v1/embeddings"
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                PROXY_API_URL,
                headers={
                    "Authorization": f"Bearer {PROXY_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "input": request.input,
                    "model": request.model
                },
                timeout=30.0
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    "embeddings": data["data"][0]["embedding"],
                    "model": request.model,
                    "dimensions": len(data["data"][0]["embedding"])
                }
            else:
                # Если API недоступен, возвращаем заглушку
                import random
                dimensions = 1536 if request.model == "text-embedding-3-small" else 3072
                return {
                    "embeddings": [random.random() for _ in range(dimensions)],
                    "model": request.model,
                    "dimensions": dimensions,
                    "note": "Демонстрационный режим"
                }
                
    except Exception as e:
        # В случае ошибки возвращаем заглушку
        import random
        dimensions = 1536 if request.model == "text-embedding-3-small" else 3072
        return {
            "embeddings": [random.random() for _ in range(dimensions)],
            "model": request.model,
            "dimensions": dimensions,
            "note": "Демонстрационный режим",
            "error": str(e)
        }

@app.get("/api/knowledge")
async def get_knowledge_base():
    """Получить базу знаний для RAG"""
    return {
        "knowledge_base": [
            {
                "id": 1,
                "title": "Промпт-инжиниринг",
                "content": "Промпт-инжиниринг - это искусство формулирования эффективных запросов к языковым моделям. Включает техники zero-shot, few-shot, chain-of-thought.",
                "category": "basic"
            },
            {
                "id": 2,
                "title": "LLM модели",
                "content": "Большие языковые модели (LLM) - это нейронные сети, обученные на больших объемах текста. Понимание их ограничений и сильных сторон ключено для эффективного использования.",
                "category": "models"
            },
            {
                "id": 3,
                "title": "RAG системы",
                "content": "Retrieval-Augmented Generation (RAG) комбинирует поиск релевантной информации с генерацией ответа, повышая точность и актуальность.",
                "category": "advanced"
            },
            {
                "id": 4,
                "title": "Векторные эмбеддинги",
                "content": "Эмбеддинги - это векторные представления текста, позволяющие измерять семантическую близость между текстами.",
                "category": "advanced"
            },
            {
                "id": 5,
                "title": "Бизнес-применение",
                "content": "AI технологии могут быть применены для автоматизации поддержки, анализа данных, создания контента и оптимизации бизнес-процессов.",
                "category": "business"
            }
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
