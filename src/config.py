"""
Configuration management using Pydantic Settings.

This module demonstrates production-ready configuration patterns commonly
tested in technical interviews for senior engineering roles.
"""

import os
from pathlib import Path
from typing import List, Optional, Union

from pydantic import Field, field_validator, ConfigDict
from pydantic_settings import BaseSettings, SettingsConfigDict


class DatabaseSettings(BaseSettings):
    """Database configuration settings."""
    
    model_config = SettingsConfigDict(env_prefix="DATABASE_")
    
    url: str = Field(default="sqlite:///./data/scientific_literature.db")
    path: str = Field(default="./data/scientific_literature.db") 
    pool_size: int = Field(default=5, ge=1, le=20)
    max_overflow: int = Field(default=10, ge=0, le=30)
    echo: bool = Field(default=False)
    
    @field_validator("path")
    @classmethod
    def ensure_data_directory(cls, v: str) -> str:
        """Ensure the data directory exists."""
        path = Path(v)
        path.parent.mkdir(parents=True, exist_ok=True)
        return str(path)


class APIKeySettings(BaseSettings):
    """API keys for external services."""
    
    model_config = SettingsConfigDict(env_prefix="")
    
    # OpenAI configuration
    openai_api_key: Optional[str] = Field(default=None, alias="OPENAI_API_KEY")
    openai_organization_id: Optional[str] = Field(default=None, alias="OPENAI_ORGANIZATION_ID")
    openai_default_model: str = Field(default="gpt-4-turbo-preview", alias="OPENAI_DEFAULT_MODEL")
    
    # Anthropic configuration
    anthropic_api_key: Optional[str] = Field(default=None, alias="ANTHROPIC_API_KEY")
    anthropic_default_model: str = Field(default="claude-3-sonnet-20240229", alias="ANTHROPIC_DEFAULT_MODEL")
    
    # ElevenLabs configuration
    elevenlabs_api_key: Optional[str] = Field(default=None, alias="ELEVENLABS_API_KEY")
    elevenlabs_voice_id: Optional[str] = Field(default=None, alias="ELEVENLABS_VOICE_ID")


class ExternalAPISettings(BaseSettings):
    """External API endpoints and rate limiting."""
    
    model_config = SettingsConfigDict(env_prefix="")
    
    # Academic data sources
    arxiv_api_base: str = Field(default="http://export.arxiv.org/api/query", alias="ARXIV_API_BASE")
    crossref_api_base: str = Field(default="https://api.crossref.org", alias="CROSSREF_API_BASE")
    semantic_scholar_api_base: str = Field(default="https://api.semanticscholar.org/graph/v1", alias="SEMANTIC_SCHOLAR_API_BASE")
    
    # Rate limiting (requests per minute)
    arxiv_rate_limit: int = Field(default=180, alias="ARXIV_RATE_LIMIT")
    crossref_rate_limit: int = Field(default=50, alias="CROSSREF_RATE_LIMIT")
    semantic_scholar_rate_limit: int = Field(default=100, alias="SEMANTIC_SCHOLAR_RATE_LIMIT")


class SparkSettings(BaseSettings):
    """Apache Spark configuration for big data processing."""
    
    model_config = SettingsConfigDict(env_prefix="SPARK_")
    
    master: str = Field(default="local[*]")
    app_name: str = Field(default="scientific-literature-intelligence")
    executor_memory: str = Field(default="2g")
    driver_memory: str = Field(default="1g")
    max_result_size: str = Field(default="1g")


class CacheSettings(BaseSettings):
    """Caching configuration."""
    
    model_config = SettingsConfigDict(env_prefix="CACHE_")
    
    dir: str = Field(default="./cache")
    ttl: int = Field(default=3600, ge=60)  # TTL in seconds, minimum 1 minute
    max_size: int = Field(default=1000, ge=10)
    
    # Redis configuration (optional)
    redis_url: Optional[str] = Field(default=None, alias="REDIS_URL")
    
    @field_validator("dir")
    @classmethod
    def ensure_cache_directory(cls, v: str) -> str:
        """Ensure the cache directory exists."""
        path = Path(v)
        path.mkdir(parents=True, exist_ok=True)
        return str(path)


class APIServerSettings(BaseSettings):
    """API server configuration."""
    
    model_config = SettingsConfigDict(env_prefix="API_")
    
    host: str = Field(default="0.0.0.0")
    port: int = Field(default=8000, ge=1, le=65535)
    reload: bool = Field(default=False)
    workers: int = Field(default=1, ge=1)
    
    # Rate limiting
    rate_limit: str = Field(default="1000/hour", alias="API_RATE_LIMIT")
    burst_limit: str = Field(default="100/minute", alias="API_BURST_LIMIT")


class SecuritySettings(BaseSettings):
    """Security and authentication settings."""
    
    model_config = SettingsConfigDict(env_prefix="")
    
    secret_key: str = Field(default="dev-secret-key-change-in-production", alias="SECRET_KEY")
    allowed_hosts: List[str] = Field(default=["localhost", "127.0.0.1"], alias="ALLOWED_HOSTS")
    
    # JWT settings
    jwt_secret_key: Optional[str] = Field(default=None, alias="JWT_SECRET_KEY")
    jwt_algorithm: str = Field(default="HS256", alias="JWT_ALGORITHM")
    jwt_expiration_hours: int = Field(default=24, ge=1, alias="JWT_EXPIRATION_HOURS")
    
    @field_validator("allowed_hosts", mode="before")
    @classmethod
    def parse_allowed_hosts(cls, v: Union[str, List[str]]) -> List[str]:
        """Parse comma-separated allowed hosts."""
        if isinstance(v, str):
            return [host.strip() for host in v.split(",")]
        return v


class FeatureFlags(BaseSettings):
    """Feature flags for gradual rollout and experimentation."""
    
    model_config = SettingsConfigDict(env_prefix="ENABLE_")
    
    # Core features
    ml_recommendations: bool = Field(default=False)
    citation_analysis: bool = Field(default=True)
    trend_analysis: bool = Field(default=True)
    collaboration_networks: bool = Field(default=True)
    full_text_search: bool = Field(default=True)
    
    # Experimental features
    real_time_updates: bool = Field(default=False)
    graph_algorithms: bool = Field(default=True)
    debug_toolbar: bool = Field(default=False)
    profiling: bool = Field(default=False)
    metrics: bool = Field(default=True)


class BatchProcessingSettings(BaseSettings):
    """Settings for batch processing and background jobs."""
    
    model_config = SettingsConfigDict(env_prefix="")
    
    # Batch sizes
    papers_batch_size: int = Field(default=1000, ge=100, alias="PAPERS_BATCH_SIZE")
    authors_batch_size: int = Field(default=500, ge=50, alias="AUTHORS_BATCH_SIZE")
    citations_batch_size: int = Field(default=2000, ge=200, alias="CITATIONS_BATCH_SIZE")
    
    # Job processing
    job_queue_url: str = Field(default="sqlite:///./data/jobs.db", alias="JOB_QUEUE_URL")
    max_concurrent_jobs: int = Field(default=4, ge=1, le=16, alias="MAX_CONCURRENT_JOBS")


class Settings(BaseSettings):
    """Main settings class that combines all configuration sections."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"  # Ignore unknown environment variables for now
    )
    
    # Environment
    environment: str = Field(default="development")
    debug: bool = Field(default=False)
    log_level: str = Field(default="INFO")
    
    # Subsections - will auto-load from environment variables
    database: DatabaseSettings = Field(default_factory=DatabaseSettings)
    api_keys: APIKeySettings = Field(default_factory=APIKeySettings)
    external_apis: ExternalAPISettings = Field(default_factory=ExternalAPISettings)
    spark: SparkSettings = Field(default_factory=SparkSettings)
    cache: CacheSettings = Field(default_factory=CacheSettings)
    api_server: APIServerSettings = Field(default_factory=APIServerSettings)
    security: SecuritySettings = Field(default_factory=SecuritySettings)
    features: FeatureFlags = Field(default_factory=FeatureFlags)
    batch: BatchProcessingSettings = Field(default_factory=BatchProcessingSettings)
    
    @property
    def is_development(self) -> bool:
        """Check if running in development mode."""
        return self.environment.lower() in ("development", "dev")
    
    @property
    def is_production(self) -> bool:
        """Check if running in production mode."""
        return self.environment.lower() in ("production", "prod")
    
    def model_post_init(self, __context) -> None:
        """Post-initialization validation and setup."""
        # In production, ensure critical settings are configured
        if self.is_production:
            if self.security.secret_key == "dev-secret-key-change-in-production":
                raise ValueError("SECRET_KEY must be changed in production")
            
            if self.debug:
                raise ValueError("DEBUG must be False in production")


# Global settings instance
settings = Settings()


def get_settings() -> Settings:
    """Get the global settings instance."""
    return settings


# For testing, we can override settings
def override_settings(**kwargs) -> Settings:
    """Create a settings instance with overrides for testing."""
    return Settings(**kwargs)