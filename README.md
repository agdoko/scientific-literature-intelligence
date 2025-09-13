# Scientific Literature Intelligence System

A comprehensive system for managing and analyzing scientific literature, designed to demonstrate mastery of SQL, Python, TypeScript, data engineering with PySpark, and API integration for technical interviews.

## 🎯 Project Purpose

This portfolio project showcases enterprise-level software engineering skills targeted at:
- **Palantir**: Complex data relationships, graph analytics, performance optimization
- **ElevenLabs**: API integration, real-time processing, content analysis
- **Anthropic/OpenAI**: Natural language processing, research literature analysis
- **General Tech Companies**: Full-stack development, database design, scalable architecture

## 🏗️ Architecture Overview

```
├── database/           # Database schema, queries, and data generation
├── src/               # Main application source code
│   ├── api/          # FastAPI REST API
│   ├── database/     # Database managers and models  
│   ├── ml/           # Machine learning and NLP components
│   ├── spark/        # PySpark data processing jobs
│   └── utils/        # Shared utilities
├── tests/            # Comprehensive test suite
├── docs/             # Documentation and API specs
└── scripts/          # Deployment and utility scripts
```

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- [uv](https://github.com/astral-sh/uv) for dependency management

### Installation

1. **Clone and setup environment:**
```bash
git clone https://github.com/agdoko/scientific-literature-intelligence.git
cd scientific-literature-intelligence
```

2. **Install dependencies with uv:**
```bash
# Install core dependencies
uv sync

# Install with all optional dependencies  
uv sync --extra all

# Or install specific feature sets
uv sync --extra dev --extra ml --extra apis
```

3. **Environment configuration:**
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your API keys and settings
nano .env
```

4. **Initialize database:**
```bash
# Run database setup
uv run python -m src.database.setup

# Generate sample data (optional)
uv run python -m src.database.sample_data_generator
```

5. **Start the development server:**
```bash
uv run python -m src.api.server
```

## 🛠️ Development Setup

### Available Commands

```bash
# Development server with auto-reload
uv run python -m src.api.server --reload

# Run tests
uv run pytest

# Run tests with coverage
uv run pytest --cov=src --cov-report=html

# Code formatting
uv run black src tests
uv run isort src tests

# Type checking  
uv run mypy src

# Linting
uv run flake8 src tests
```

### Optional Dependencies

The project uses optional dependency groups for different use cases:

```bash
# Development tools
uv sync --extra dev

# Machine learning components
uv sync --extra ml

# API integrations (OpenAI, Claude, ElevenLabs)
uv sync --extra apis

# Big data processing with PySpark
uv sync --extra spark

# Data visualization
uv sync --extra viz

# Everything
uv sync --extra all
```

## 🗄️ Database Design

The system uses a sophisticated relational database schema modeling scientific literature:

- **Authors**: Researcher information and metrics
- **Papers**: Research papers with metadata and full-text
- **Citations**: Citation network for graph analysis
- **Datasets**: Research data provenance tracking
- **Collaborations**: Author collaboration networks

Key features:
- Full-text search with SQLite FTS5
- Complex graph relationships for citation analysis
- Temporal data modeling for trend analysis
- Performance optimization with strategic indexing

## 🔧 Configuration Management

The project uses Pydantic Settings for type-safe configuration management:

```python
from src.config import settings

# Access database settings
db_url = settings.database.url

# Check feature flags
if settings.features.ml_recommendations:
    # Enable ML features
    pass

# Environment-specific behavior
if settings.is_production:
    # Production-specific logic
    pass
```

## 🧪 Testing Strategy

Comprehensive testing with pytest:
- **Unit tests**: Individual component testing
- **Integration tests**: Database and API testing  
- **Performance tests**: Query optimization validation
- **End-to-end tests**: Complete workflow testing

```bash
# Run specific test categories
uv run pytest -m unit
uv run pytest -m integration
uv run pytest -m "not slow"
```

## 📊 Data Engineering Pipeline

The system demonstrates several data engineering patterns:

1. **ETL Processing**: Extract from academic APIs, transform, load to database
2. **Batch Processing**: PySpark jobs for large-scale analysis
3. **Real-time Processing**: Streaming updates for live data
4. **Data Quality**: Validation, monitoring, and error handling

## 🔌 API Integration

Integrated with multiple external services:
- **OpenAI GPT**: Paper summarization and analysis
- **Anthropic Claude**: Research question answering
- **ElevenLabs**: Text-to-speech for accessibility
- **Academic APIs**: arXiv, Crossref, Semantic Scholar

## 🚀 Deployment

The project is containerized and cloud-ready:

```bash
# Docker deployment
docker build -t sci-lit-intelligence .
docker run -p 8000:8000 sci-lit-intelligence

# Or with docker-compose
docker-compose up
```

## 📈 Performance Considerations

- **Database Optimization**: Strategic indexing, query optimization
- **Caching**: Multi-level caching with Redis integration
- **Connection Pooling**: Efficient database connection management
- **Async Processing**: FastAPI with async/await patterns
- **Background Jobs**: Celery for long-running tasks

## 🎓 Learning Resources

- [`SCHEMA_EXPLAINED.md`](./SCHEMA_EXPLAINED.md) - Comprehensive database design explanation
- [`docs/`](./docs/) - API documentation and architectural decisions
- [`examples/`](./examples/) - Code examples and usage patterns

## 🤝 Contributing

This is a portfolio project, but feedback and suggestions are welcome:

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🏆 Interview Highlights

This project demonstrates:

### Technical Skills
- **Database Design**: Complex relational schemas, indexing, query optimization
- **Python Engineering**: Type hints, async programming, design patterns
- **API Development**: RESTful APIs, authentication, rate limiting
- **Data Engineering**: ETL pipelines, batch processing, data validation
- **Testing**: Comprehensive test coverage, mocking, performance testing

### Architecture Patterns
- **Configuration Management**: Environment-based settings, secrets management
- **Dependency Injection**: Modular, testable architecture
- **Error Handling**: Comprehensive logging, monitoring, graceful degradation
- **Performance**: Caching strategies, connection pooling, async processing
- **Security**: Authentication, authorization, input validation

### Domain Expertise
- **Academic Research**: Understanding of citation networks, research metrics
- **Natural Language Processing**: Text analysis, similarity detection
- **Graph Analytics**: Network analysis, centrality metrics
- **Time Series Analysis**: Trend detection, forecasting
- **Data Visualization**: Interactive dashboards, research insights

---

*Built with ❤️ for technical interviews and portfolio demonstration*