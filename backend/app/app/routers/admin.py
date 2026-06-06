"""Server-rendered admin dashboard: view usage, change budgets, reset spend."""

from pathlib import Path

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from .. import litellm_client
from ..config import get_settings
from ..db import get_db
from ..errors import NotFoundError
from ..models import Device
from ..security import (
    create_admin_session,
    is_valid_admin_session,
    verify_admin_password,
)

router = APIRouter(prefix="/admin", tags=["admin"])

_SESSION_COOKIE = "admin_session"
templates = Jinja2Templates(directory=str(Path(__file__).resolve().parent.parent / "templates"))


def require_admin(request: Request) -> None:
    """Guard dependency: redirect-raising auth check for admin pages."""
    if not is_valid_admin_session(request.cookies.get(_SESSION_COOKIE)):
        raise _LoginRedirect()


class _LoginRedirect(Exception):
    """Raised to bounce unauthenticated admins to the login page."""


@router.get("/login", response_class=HTMLResponse)
async def login_form(request: Request) -> HTMLResponse:
    return templates.TemplateResponse(request, "login.html", {"error": None})


@router.post("/login")
async def login(request: Request, password: str = Form(...)) -> RedirectResponse:
    if not verify_admin_password(password):
        return templates.TemplateResponse(  # type: ignore[return-value]
            request, "login.html", {"error": "Incorrect password."}, status_code=401
        )
    response = RedirectResponse(url="/admin", status_code=303)
    response.set_cookie(
        _SESSION_COOKIE,
        create_admin_session(),
        httponly=True,
        samesite="lax",
    )
    return response


@router.get("", response_class=HTMLResponse)
async def users_list(
    request: Request, db: Session = Depends(get_db), _: None = Depends(require_admin)
) -> HTMLResponse:
    settings = get_settings()
    devices = db.query(Device).order_by(Device.created_at.desc()).all()
    rows = []
    for device in devices:
        info = await litellm_client.get_user_info(device.litellm_user_id)
        user = info.get("user_info") or info
        keys = info.get("keys") or []
        rows.append(
            {
                "device_id": device.device_id,
                "litellm_user_id": device.litellm_user_id,
                "budget": user.get("max_budget", settings.default_budget_usd),
                "spend": user.get("spend", 0.0) or 0.0,
                "requests": sum(k.get("key_count", 0) or 0 for k in keys) if keys else None,
                "created_at": device.created_at,
            }
        )
    return templates.TemplateResponse(request, "users.html", {"rows": rows})


@router.get("/users/{litellm_user_id}", response_class=HTMLResponse)
async def user_detail(
    request: Request,
    litellm_user_id: str,
    db: Session = Depends(get_db),
    _: None = Depends(require_admin),
) -> HTMLResponse:
    device = _device_or_404(db, litellm_user_id)
    info = await litellm_client.get_user_info(litellm_user_id)
    user = info.get("user_info") or info
    logs = await litellm_client.get_spend_logs(litellm_user_id)
    return templates.TemplateResponse(
        request,
        "user_detail.html",
        {
            "device_id": device.device_id,
            "litellm_user_id": litellm_user_id,
            "budget": user.get("max_budget", get_settings().default_budget_usd),
            "spend": user.get("spend", 0.0) or 0.0,
            "logs": logs,
        },
    )


@router.post("/users/{litellm_user_id}/budget")
async def update_budget(
    litellm_user_id: str,
    max_budget: float = Form(...),
    db: Session = Depends(get_db),
    _: None = Depends(require_admin),
) -> RedirectResponse:
    _device_or_404(db, litellm_user_id)
    await litellm_client.update_user_budget(litellm_user_id, max_budget)
    return RedirectResponse(url=f"/admin/users/{litellm_user_id}", status_code=303)


@router.post("/users/{litellm_user_id}/reset")
async def reset_spend(
    litellm_user_id: str,
    db: Session = Depends(get_db),
    _: None = Depends(require_admin),
) -> RedirectResponse:
    _device_or_404(db, litellm_user_id)
    await litellm_client.reset_user_spend(litellm_user_id)
    return RedirectResponse(url=f"/admin/users/{litellm_user_id}", status_code=303)


def _device_or_404(db: Session, litellm_user_id: str) -> Device:
    device = (
        db.query(Device)
        .filter(Device.litellm_user_id == litellm_user_id)
        .one_or_none()
    )
    if device is None:
        raise NotFoundError("Unknown user.")
    return device
