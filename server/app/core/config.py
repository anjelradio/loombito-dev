from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = Field(..., env="DATABASE_URL")
    JWT_SECRET: str = Field(..., env="JWT_SECRET")
    JWT_ALG: str = Field(default="HS256", env="JWT_ALG")
    JWT_EXPIRES_MIN: int = Field(default=60 * 24, env="JWT_EXPIRES_MIN")

    BREVO_API_KEY: str = Field(..., env="BREVO_API_KEY")
    BREVO_SENDER_EMAIL: str = Field(..., env="BREVO_SENDER_EMAIL")
    BREVO_SENDER_NAME: str = Field(default="LoomBo", env="BREVO_SENDER_NAME")

    OTP_LENGTH: int = Field(default=6, env="OTP_LENGTH")
    OTP_EXPIRES_MIN: int = Field(default=5, env="OTP_EXPIRES_MIN")
    OTP_MAX_ATTEMPTS: int = Field(default=5, env="OTP_MAX_ATTEMPTS")
    OTP_RESEND_COOLDOWN_SEC: int = Field(default=60, env="OTP_RESEND_COOLDOWN_SEC")

    REDIS_URL: str = Field(..., env="REDIS_URL")
    AUDIT_ENCRYPTION_KEY: str = Field(..., env="AUDIT_ENCRYPTION_KEY")
    AUDIT_ACCESS_KEY_LENGTH: int = Field(default=10, env="AUDIT_ACCESS_KEY_LENGTH")
    AUDIT_ACCESS_EXPIRES_MIN: int = Field(default=10, env="AUDIT_ACCESS_EXPIRES_MIN")
    AUDIT_ACCESS_MAX_ATTEMPTS: int = Field(default=5, env="AUDIT_ACCESS_MAX_ATTEMPTS")
    AUDIT_ACCESS_SESSION_SEC: int = Field(default=1800, env="AUDIT_ACCESS_SESSION_SEC")

    STRIPE_SECRET_KEY: str = Field(default="", env="STRIPE_SECRET_KEY")
    STRIPE_WEBHOOK_SECRET: str = Field(default="", env="STRIPE_WEBHOOK_SECRET")
    STRIPE_PRICE_ID_PROFESSIONAL: str = Field(
        default="", env="STRIPE_PRICE_ID_PROFESSIONAL"
    )
    STRIPE_PRICE_ID_INSTITUTIONAL: str = Field(
        default="", env="STRIPE_PRICE_ID_INSTITUTIONAL"
    )
    APP_BASE_URL: str = Field(default="http://localhost:3000", env="APP_BASE_URL")

    GEMINI_API_KEY: str = Field(default="", env="GEMINI_API_KEY")
    GEMINI_MODEL_PRIMARY: str = Field(default="gemini-2.5-flash", env="GEMINI_MODEL_PRIMARY")
    GEMINI_MODEL_FALLBACKS: str = Field(
        default="gemini-2.5-flash-lite,gemini-1.5-flash",
        env="GEMINI_MODEL_FALLBACKS",
    )
    GEMINI_TIMEOUT_SEC: int = Field(default=30, env="GEMINI_TIMEOUT_SEC")

    FIREBASE_CREDENTIALS_PATH: str = Field(default="", env="FIREBASE_CREDENTIALS_PATH")
    FIREBASE_CREDENTIALS_JSON: str = Field(default="", env="FIREBASE_CREDENTIALS_JSON")
    FIREBASE_PROJECT_ID: str = Field(default="", env="FIREBASE_PROJECT_ID")

    BACKUP_STORAGE_DIR: str = Field(default="storage/backups", env="BACKUP_STORAGE_DIR")

    MAX_LICENSES_PER_MONTH: int = Field(default=2, env="MAX_LICENSES_PER_MONTH")

    PROJECT_NAME: str = "LoomBo - API"
    ENVIRONMENT: str = Field(..., env="ENVIRONMENT")

    LANGUAGE_CODE: str = "es"
    TIME_ZONE: str = "America/La_Paz"

    class Config:
        env_file = ".env"

    @property
    def DATABASE_URL_NORMALIZED(self) -> str:
        url = self.DATABASE_URL
        if url.startswith("postgres://"):
            return "postgresql+psycopg://" + url[len("postgres://") :]
        if url.startswith("postgresql://") and "+psycopg" not in url:
            return "postgresql+psycopg://" + url[len("postgresql://") :]
        return url


settings = Settings()
