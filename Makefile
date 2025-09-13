# Scientific Literature Intelligence System - Development Commands

.PHONY: help install dev test lint format type-check clean run-server setup-db sample-data

# Default target
help: ## Show this help message
	@echo "Scientific Literature Intelligence System"
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Installation and setup
install: ## Install dependencies with uv
	uv sync

install-all: ## Install all optional dependencies
	uv sync --extra all

install-dev: ## Install with development dependencies
	uv sync --extra dev

# Development commands
dev: ## Start development server with auto-reload
	uv run python -m src.api.server --reload

run-server: ## Start production server
	uv run python -m src.api.server

# Database management
setup-db: ## Initialize database schema
	uv run python -m src.database.setup

sample-data: ## Generate sample data for development
	uv run python -m src.database.sample_data_generator

reset-db: ## Reset database (WARNING: destroys all data)
	rm -f data/scientific_literature.db
	$(MAKE) setup-db

# Testing
test: ## Run all tests
	uv run pytest

test-unit: ## Run unit tests only
	uv run pytest -m unit

test-integration: ## Run integration tests only  
	uv run pytest -m integration

test-fast: ## Run tests excluding slow tests
	uv run pytest -m "not slow"

test-coverage: ## Run tests with coverage report
	uv run pytest --cov=src --cov-report=html --cov-report=term-missing

# Code quality
lint: ## Run all linting checks
	uv run flake8 src tests
	uv run mypy src

format: ## Format code with black and isort
	uv run black src tests
	uv run isort src tests

format-check: ## Check if code formatting is correct
	uv run black --check src tests
	uv run isort --check-only src tests

type-check: ## Run type checking with mypy
	uv run mypy src

# Pre-commit hooks
pre-commit-install: ## Install pre-commit hooks
	uv run pre-commit install

pre-commit-run: ## Run pre-commit on all files
	uv run pre-commit run --all-files

# Cleaning
clean: ## Clean up generated files
	find . -type d -name "__pycache__" -delete
	find . -type f -name "*.pyc" -delete  
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf build/
	rm -rf dist/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/

clean-db: ## Clean database files
	rm -f data/*.db
	rm -f data/*.db-journal

# Documentation
docs-serve: ## Serve documentation locally
	uv run mkdocs serve

docs-build: ## Build documentation
	uv run mkdocs build

# Data processing
spark-submit: ## Submit Spark job (requires SPARK_JOB parameter)
	uv run spark-submit src/spark/jobs/$(SPARK_JOB).py

# Quality gates (for CI/CD)
check: format-check lint type-check test ## Run all quality checks

ci: ## Run CI pipeline locally
	$(MAKE) clean
	$(MAKE) install-dev
	$(MAKE) check
	$(MAKE) test-coverage

# Environment management
env-template: ## Copy environment template
	cp .env.example .env
	@echo "Don't forget to edit .env with your actual values!"

# Docker commands
docker-build: ## Build Docker image
	docker build -t scientific-literature-intelligence .

docker-run: ## Run Docker container
	docker run -p 8000:8000 --env-file .env scientific-literature-intelligence

docker-compose-up: ## Start services with docker-compose
	docker-compose up -d

docker-compose-down: ## Stop services with docker-compose
	docker-compose down

# Development utilities
shell: ## Start Python shell with project context
	uv run python -c "from src.config import settings; print('Settings loaded. Available: settings'); import IPython; IPython.start_ipython(argv=[])"

notebook: ## Start Jupyter notebook
	uv run jupyter notebook

# Security
security-check: ## Run security checks
	uv run safety check
	uv run bandit -r src/

# Performance
profile: ## Run performance profiling
	uv run python -m cProfile -o profile.stats -m src.api.server
	@echo "Profile saved to profile.stats"

# Git hooks
hooks: ## Install development hooks
	$(MAKE) pre-commit-install
	@echo "Git hooks installed successfully"

# Full development setup
setup: ## Complete development environment setup
	$(MAKE) install-all
	$(MAKE) env-template
	$(MAKE) setup-db
	$(MAKE) hooks
	@echo ""
	@echo "🎉 Setup complete! Next steps:"
	@echo "1. Edit .env with your API keys and configuration"
	@echo "2. Run 'make sample-data' to generate test data"
	@echo "3. Run 'make dev' to start the development server"