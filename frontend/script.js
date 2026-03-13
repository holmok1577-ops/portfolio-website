// ============================================
// AI DEVELOPER PORTFOLIO - MAIN SCRIPT
// ============================================

// API Configuration
const API_URL = window.location.origin.includes('localhost') ? 'http://localhost:5000' : '';

// ============================================
// DATA MANAGEMENT
// ============================================

let siteData = {
    hero: {
        title: 'Промпт-инженер & AI-разработчик',
        subtitle: 'Создаю эффективные решения на основе AI',
        description: 'Веду проекты от идеи до финала',
        stats: [
            { number: '50+', label: 'Проектов' },
            { number: '1+', label: 'Год поддержки' },
            { number: '100%', label: 'Гарантия' }
        ]
    },
    about: {
        lead: 'Меня зовут Станислав, и я профессиональный промпт-инженер.',
        text: 'Веду проекты от идеи до финала. Специализируюсь на LLM, RAG-системах и бизнес-интеграции AI.',
        guarantee: {
            title: 'Годовая поддержка',
            text: 'Бесплатная поддержка всех проектов в течение первого года.'
        },
        skills: ['LLM & GPT', 'AI-ассистенты', 'RAG системы', 'Промпт-инжиниринг', 'Python', 'Telegram боты']
    },
    services: [
        { id: 1, icon: 'fas fa-robot', title: 'Телеграм-бот с AI', description: 'Интеллектуальный бот для вашего бизнеса с интеграцией GPT' },
        { id: 2, icon: 'fas fa-brain', title: 'AI-ассистент', description: 'Персональный AI-помощник для автоматизации задач' },
        { id: 3, icon: 'fas fa-database', title: 'RAG-система', description: 'База знаний с семантическим поиском и AI-ответами' },
        { id: 4, icon: 'fas fa-comments', title: 'Чат-бот поддержки', description: 'Автоматизация ответов на частые вопросы клиентов' }
    ],
    projects: [
        { id: 1, title: 'AI Telegram Bot', technology: 'Python, OpenAI, FastAPI', description: 'Интеллектуальный бот для автоматизации бизнес-процессов', link: 'https://github.com/holmok1577-ops', image: '' },
        { id: 2, title: 'RAG Knowledge Base', technology: 'Python, ChromaDB, LangChain', description: 'Система поиска по документам с AI-генерацией ответов', link: 'https://github.com/holmok1577-ops', image: '' }
    ],
    contacts: {
        email: 'email@example.com',
        telegram: '@username',
        phone: '+7 (999) 123-45-67',
        github: 'https://github.com/holmok1577-ops',
        docker: 'https://hub.docker.com/repositories/holmok1577'
    },
    chatbot: {
        welcome: 'Привет! Я AI-ассистент Станислава. Могу рассказать о промпт-инжиниринге, LLM моделях и AI-решениях.',
        quickQuestions: ['Сколько стоит разработка бота?', 'Какие сроки разработки?', 'Расскажи о примерах работ']
    }
};

// Load data from localStorage
function loadSiteData() {
    const saved = localStorage.getItem('siteData');
    if (saved) {
        try {
            const parsed = JSON.parse(saved);
            siteData = { ...siteData, ...parsed };
        } catch (e) {
            console.error('Error loading data:', e);
        }
    }
}

// Save data to localStorage
function saveSiteData() {
    localStorage.setItem('siteData', JSON.stringify(siteData));
}

// Listen for data updates from admin panel
window.addEventListener('message', (e) => {
    if (e.data && e.data.type === 'dataUpdated') {
        loadSiteData();
        renderAll();
        showNotification('Данные обновлены', 'success');
    }
});

window.addEventListener('storage', (e) => {
    if (e.key === 'siteData') {
        loadSiteData();
        renderAll();
    }
});

// ============================================
// RENDER FUNCTIONS
// ============================================

function renderAll() {
    renderHero();
    renderAbout();
    renderServices();
    renderProjects();
    renderContacts();
}

function renderHero() {
    const subtitle = document.getElementById('heroSubtitle');
    const stats = document.getElementById('heroStats');
    
    if (subtitle) {
        subtitle.textContent = siteData.hero.subtitle + ' ' + siteData.hero.description;
    }
    
    if (stats && siteData.hero.stats) {
        stats.innerHTML = siteData.hero.stats.map(stat => `
            <div class="stat-item">
                <span class="stat-number">${stat.number}</span>
                <span class="stat-label">${stat.label}</span>
            </div>
        `).join('');
    }
}

function renderAbout() {
    const lead = document.querySelector('.about-text .lead');
    const text = document.querySelectorAll('.about-text p')[1];
    const guaranteeTitle = document.querySelector('.guarantee-content h4');
    const guaranteeText = document.querySelector('.guarantee-content p');
    const skillsGrid = document.getElementById('skillsGrid');
    
    if (lead) lead.textContent = siteData.about.lead;
    if (text) text.textContent = siteData.about.text;
    if (guaranteeTitle) guaranteeTitle.textContent = siteData.about.guarantee.title;
    if (guaranteeText) guaranteeText.textContent = siteData.about.guarantee.text;
    
    if (skillsGrid && siteData.about.skills) {
        const skillIcons = {
            'LLM & GPT': 'fas fa-brain',
            'AI-ассистенты': 'fas fa-robot',
            'RAG системы': 'fas fa-database',
            'Промпт-инжиниринг': 'fas fa-code',
            'Python': 'fab fa-python',
            'Telegram боты': 'fas fa-comments'
        };
        
        skillsGrid.innerHTML = siteData.about.skills.map(skill => `
            <div class="skill-card">
                <div class="skill-icon"><i class="${skillIcons[skill] || 'fas fa-star'}"></i></div>
                <span>${skill}</span>
            </div>
        `).join('');
    }
}

function renderServices() {
    const container = document.getElementById('servicesGrid');
    if (!container || !siteData.services) return;
    
    container.innerHTML = siteData.services.map(service => `
        <div class="service-card" data-aos="fade-up">
            <div class="service-icon"><i class="${service.icon}"></i></div>
            <h3>${service.title}</h3>
            <p>${service.description}</p>
        </div>
    `).join('');
}

function renderProjects() {
    const container = document.getElementById('projectsGrid');
    if (!container || !siteData.projects) return;
    
    container.innerHTML = siteData.projects.map(project => `
        <div class="project-card" data-aos="fade-up">
            <div class="project-image">
                ${project.image ? `<img src="${project.image}" alt="${project.title}" style="width:100%; height:100%; object-fit:cover; border-radius:8px;">` : '<i class="fas fa-code"></i>'}
            </div>
            <div class="project-content">
                <span class="project-tech">${project.technology}</span>
                <h3>${project.title}</h3>
                <p>${project.description}</p>
                <a href="${project.link}" target="_blank" class="project-link">
                    Смотреть проект <i class="fas fa-arrow-right"></i>
                </a>
            </div>
        </div>
    `).join('');
}

function renderContacts() {
    const container = document.getElementById('contactLinks');
    if (!container || !siteData.contacts) return;
    
    const links = container.querySelectorAll('.contact-link');
    if (links[0]) links[0].querySelector('span').textContent = siteData.contacts.email;
    if (links[1]) {
        links[1].querySelector('span').textContent = siteData.contacts.telegram;
        links[1].href = 'https://t.me/' + siteData.contacts.telegram.replace('@', '');
    }
    if (links[2]) {
        links[2].querySelector('span').textContent = siteData.contacts.phone;
        links[2].href = 'tel:' + siteData.contacts.phone.replace(/[^\d+]/g, '');
    }
    
    const socials = document.querySelectorAll('.social-link');
    if (socials[0]) socials[0].href = siteData.contacts.github;
    if (socials[1]) socials[1].href = siteData.contacts.docker;
}

// ============================================
// NAVIGATION & UI
// ============================================

function initNavigation() {
    const navbar = document.getElementById('navbar');
    const navToggle = document.getElementById('navToggle');
    const navMenu = document.getElementById('navMenu');
    
    // Scroll effect
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });
    
    // Mobile toggle
    if (navToggle) {
        navToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
        });
    }
    
    // Smooth scroll for nav links
    document.querySelectorAll('.nav-link[href^="#"]').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const target = document.querySelector(link.getAttribute('href'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
                navMenu.classList.remove('active');
            }
        });
    });
    
    // Active link on scroll
    window.addEventListener('scroll', () => {
        let current = '';
        document.querySelectorAll('section[id]').forEach(section => {
            const sectionTop = section.offsetTop - 100;
            if (window.scrollY >= sectionTop) {
                current = section.getAttribute('id');
            }
        });
        
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === '#' + current) {
                link.classList.add('active');
            }
        });
    });
}

function initThemeToggle() {
    const themeToggle = document.getElementById('themeToggle');
    const html = document.documentElement;
    
    const savedTheme = localStorage.getItem('theme') || 'dark';
    html.setAttribute('data-theme', savedTheme);
    updateThemeIcon(savedTheme);
    
    if (themeToggle) {
        themeToggle.addEventListener('click', () => {
            const current = html.getAttribute('data-theme');
            const newTheme = current === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            updateThemeIcon(newTheme);
        });
    }
}

function updateThemeIcon(theme) {
    const icon = document.querySelector('#themeToggle i');
    if (icon) {
        icon.className = theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
    }
}

// ============================================
// CHAT WIDGET
// ============================================

function initChatWidget() {
    const chatWidget = document.getElementById('chatWidget');
    const chatToggle = document.getElementById('chatToggle');
    const chatContainer = document.getElementById('chatContainer');
    const chatClose = document.getElementById('chatClose');
    const chatInput = document.getElementById('chatInput');
    const chatSend = document.getElementById('chatSend');
    const chatMessages = document.getElementById('chatMessages');
    
    if (!chatWidget) return;
    
    // Toggle chat
    chatToggle.addEventListener('click', () => {
        chatContainer.classList.toggle('active');
        if (chatContainer.classList.contains('active')) {
            chatInput.focus();
        }
    });
    
    chatClose.addEventListener('click', () => {
        chatContainer.classList.remove('active');
    });
    
    // Quick questions
    document.querySelectorAll('.quick-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const question = btn.getAttribute('data-question');
            addMessage(question, 'user');
            processMessage(question);
        });
    });
    
    // Send message
    function sendMessage() {
        const text = chatInput.value.trim();
        if (!text) return;
        
        addMessage(text, 'user');
        chatInput.value = '';
        chatInput.style.height = 'auto';
        
        processMessage(text);
    }
    
    chatSend.addEventListener('click', sendMessage);
    
    chatInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    
    chatInput.addEventListener('input', () => {
        chatInput.style.height = 'auto';
        chatInput.style.height = Math.min(chatInput.scrollHeight, 120) + 'px';
    });
    
    // Add message to chat
    function addMessage(text, type) {
        const div = document.createElement('div');
        div.className = 'message ' + type;
        div.innerHTML = `<p>${escapeHtml(text)}</p>`;
        chatMessages.appendChild(div);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }
    
    // Process message and get response
    async function processMessage(text) {
        // Show typing indicator
        const typing = document.createElement('div');
        typing.className = 'message ai typing';
        typing.innerHTML = '<p><i>печатает...</i></p>';
        chatMessages.appendChild(typing);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        
        // Check for quick responses
        const lower = text.toLowerCase();
        let response = '';
        
        if (lower.includes('стоит') || lower.includes('цена') || lower.includes('сколько')) {
            response = 'Стоимость разработки зависит от сложности проекта. Телеграм-бот от 30 000 ₽, AI-ассистент от 50 000 ₽. Давайте обсудим детали — оставьте заявку в форме ниже!';
        } else if (lower.includes('срок') || lower.includes('время')) {
            response = 'Средние сроки: простой бот — 1-2 недели, AI-ассистент — 2-4 недели, сложная RAG-система — 1-2 месяца. Точные сроки определяются после обсуждения ТЗ.';
        } else if (lower.includes('пример') || lower.includes('портфолио')) {
            response = 'У меня в портфолио проекты: AI чат-бот для поддержки клиентов, RAG-система для поиска по документам, автономный агент для обработки заявок. Полный список в разделе "Проекты" на сайте!';
        } else if (lower.includes('консультация')) {
            response = 'Консультация бесплатна! Могу обсудить ваш проект, подобрать оптимальное решение и рассчитать стоимость. Оставьте заявку — я свяжусь в течение 24 часов.';
        } else if (lower.includes('что ты умеешь') || lower.includes('кто ты') || lower.includes('ты кто')) {
            response = siteData.chatbot?.welcome || 'Привет! Я Станислав, ваш AI-ассистент. Могу рассказать о промпт-инжиниринге, LLM моделях и AI-решениях.';
        } else {
            // Try to get response from API
            try {
                const res = await fetch(`${API_URL}/api/chat/direct`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: text, model: 'gpt-3.5-turbo' })
                });
                
                if (res.ok) {
                    const data = await res.json();
                    response = data.response;
                } else {
                    response = 'Я могу ответить на вопросы о промпт-инжиниринге, LLM моделях, создании ботов и AI-ассистентов. Задайте конкретный вопрос! 😊';
                }
            } catch (e) {
                response = 'Я могу ответить на вопросы о промпт-инжиниринге, LLM моделях, создании ботов и AI-ассистентов. Задайте конкретный вопрос! 😊';
            }
        }
        
        // Remove typing indicator and add response
        typing.remove();
        addMessage(response, 'ai');
    }
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// ============================================
// CONTACT FORM
// ============================================

function initContactForm() {
    const form = document.getElementById('contactForm');
    if (!form) return;
    
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const data = {
            name: document.getElementById('formName').value,
            email: document.getElementById('formEmail').value,
            service_type: document.getElementById('formService').value,
            message: document.getElementById('formMessage').value
        };
        
        try {
            const res = await fetch(`${API_URL}/api/request`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            if (res.ok) {
                showNotification('Заявка отправлена! Я свяжусь с вами.', 'success');
                form.reset();
            } else {
                showNotification('Ошибка отправки. Попробуйте позже.', 'error');
            }
        } catch (e) {
            // If API unavailable, still show success (demo mode)
            showNotification('Заявка отправлена! Я свяжусь с вами.', 'success');
            form.reset();
        }
    });
}

// ============================================
// NOTIFICATION
// ============================================

function showNotification(message, type = 'success') {
    const existing = document.querySelector('.notification');
    if (existing) existing.remove();
    
    const notif = document.createElement('div');
    notif.className = 'notification ' + type;
    notif.textContent = message;
    document.body.appendChild(notif);
    
    setTimeout(() => notif.remove(), 3000);
}

// ============================================
// INITIALIZATION
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    // Load data
    loadSiteData();
    
    // Initialize AOS
    if (typeof AOS !== 'undefined') {
        AOS.init({
            duration: 800,
            easing: 'ease-out',
            once: true,
            offset: 100
        });
    }
    
    // Initialize all components
    initNavigation();
    initChatWidget();
    initContactForm();
    
    // Render content
    renderAll();
    
    console.log('✅ Site initialized successfully');
});
