from fastapi import APIRouter, Depends, Response, status
from fastapi.security import OAuth2PasswordRequestForm

from app.dependencies.auth import (
    CurrentActor,
    CurrentRequestActor,
    CurrentUser,
    DBSession,
    oauth2_scheme,
)
from app.modules.auth.schemas import (
    LoginRequest,
    LoginResponse,
    RequestEmailOtpResponse,
    UpdateEmailRequest,
    UpdatePasswordRequest,
    RegisterRequest,
    RequestPasswordResetOtpRequest,
    RequestPasswordResetOtpResponse,
    UserProfileUpdate,
    UserRead,
    VerifyEmailOtpRequest,
    VerifyEmailOtpResponse,
    VerifyPasswordResetOtpRequest,
    VerifyPasswordResetOtpResponse,
)
from app.modules.auth.services import (
    AccountService,
    AuthService,
    PasswordResetService,
)

router = APIRouter(prefix="/auth", tags=["Autenticacion"])


@router.post(
    "/register", response_model=LoginResponse, status_code=status.HTTP_201_CREATED
)
def register(db: DBSession, payload: RegisterRequest, request: CurrentRequestActor):
    service = AuthService(db)
    token, user = service.register_with_token(payload, request)

    return {"user": user, "access_token": token}


@router.post("/login", response_model=LoginResponse)
def login(db: DBSession, payload: LoginRequest, request: CurrentRequestActor):
    service = AuthService(db)
    token, user = service.login(payload.email, payload.password, request)

    return {"user": user, "access_token": token}


@router.post("/token", response_model=LoginResponse)
def token_login(
    db: DBSession,
    request: CurrentRequestActor,
    form: OAuth2PasswordRequestForm = Depends(),
):
    email = form.username
    password = form.password
    service = AuthService(db)
    token, user = service.login(email, password, request)

    return {"user": user, "access_token": token}


@router.post("/check-status", response_model=LoginResponse)
def check_status(user: CurrentUser, token: str = Depends(oauth2_scheme)):
    return {"user": user, "access_token": token}


@router.patch("/me/profile", response_model=UserRead)
def update_profile(db: DBSession, payload: UserProfileUpdate, actor: CurrentActor):
    service = AccountService(db)
    return service.update_profile(actor, payload)


@router.post("/me/email/request-otp", response_model=RequestEmailOtpResponse)
async def request_email_otp(db: DBSession, actor: CurrentActor):
    service = AccountService(db)
    return await service.request_email_change_otp(actor)


@router.post("/me/email/verify-otp", response_model=VerifyEmailOtpResponse)
def verify_email_otp(db: DBSession, payload: VerifyEmailOtpRequest, actor: CurrentActor):
    service = AccountService(db)
    return service.verify_email_change_otp(actor, payload)


@router.patch("/me/email", response_model=UserRead)
def update_email(db: DBSession, payload: UpdateEmailRequest, actor: CurrentActor):
    service = AccountService(db)
    return service.update_email(actor, payload)


@router.patch("/me/password", status_code=status.HTTP_204_NO_CONTENT)
def update_password(db: DBSession, payload: UpdatePasswordRequest, actor: CurrentActor):
    service = AccountService(db)
    service.update_password(actor, payload)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/password/request-otp", response_model=RequestPasswordResetOtpResponse)
async def request_password_reset_otp(
    db: DBSession,
    payload: RequestPasswordResetOtpRequest,
    actor: CurrentRequestActor,
):
    service = PasswordResetService(db)
    return await service.request_password_reset_otp(payload, actor)


@router.post("/password/verify-otp", response_model=VerifyPasswordResetOtpResponse)
async def verify_password_reset_otp(
    db: DBSession,
    payload: VerifyPasswordResetOtpRequest,
    actor: CurrentRequestActor,
):
    service = PasswordResetService(db)
    return await service.verify_password_reset_otp(payload, actor)
