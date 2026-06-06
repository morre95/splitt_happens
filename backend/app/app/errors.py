"""Custom exceptions and handlers producing a consistent error envelope.

Every error returns:
    {"success": false, "error": {"code": "UPPER_SNAKE", "message": "..."}}
"""

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


class AppError(Exception):
    """Base class for domain errors mapped to a status + machine-readable code."""

    status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR
    code: str = "INTERNAL_ERROR"

    def __init__(self, message: str):
        self.message = message
        super().__init__(message)


class UnauthorizedError(AppError):
    status_code = status.HTTP_401_UNAUTHORIZED
    code = "UNAUTHORIZED"


class BudgetExceededError(AppError):
    status_code = status.HTTP_402_PAYMENT_REQUIRED
    code = "BUDGET_EXCEEDED"


class NotFoundError(AppError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "NOT_FOUND"


class UpstreamError(AppError):
    status_code = status.HTTP_502_BAD_GATEWAY
    code = "UPSTREAM_ERROR"


def _envelope(code: str, message: str, status_code: int) -> JSONResponse:
    return JSONResponse(
        status_code=status_code,
        content={"success": False, "error": {"code": code, "message": message}},
    )


def register_exception_handlers(app: FastAPI) -> None:
    """Wire centralized handlers so every error has the same shape."""

    @app.exception_handler(AppError)
    async def _handle_app_error(_: Request, exc: AppError) -> JSONResponse:
        return _envelope(exc.code, exc.message, exc.status_code)

    @app.exception_handler(RequestValidationError)
    async def _handle_validation(_: Request, exc: RequestValidationError) -> JSONResponse:
        return _envelope(
            "VALIDATION_ERROR",
            "; ".join(e["msg"] for e in exc.errors()) or "Invalid request.",
            status.HTTP_400_BAD_REQUEST,
        )
