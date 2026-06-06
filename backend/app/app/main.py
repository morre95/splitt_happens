"""FastAPI application factory."""

from fastapi import FastAPI, Request
from fastapi.responses import RedirectResponse

from .errors import register_exception_handlers
from .routers import admin, auth, proxy


def create_app() -> FastAPI:
    app = FastAPI(title="Split Happens Backend")

    register_exception_handlers(app)

    @app.exception_handler(admin._LoginRedirect)
    async def _login_redirect(_: Request, __: admin._LoginRedirect) -> RedirectResponse:
        return RedirectResponse(url="/admin/login", status_code=303)

    app.include_router(auth.router)
    app.include_router(proxy.router)
    app.include_router(admin.router)

    @app.get("/healthz", tags=["health"])
    async def healthz() -> dict[str, bool]:
        return {"ok": True}

    return app


app = create_app()
