import random
import string
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
import jwt

from ..database import get_db
from ..models import User, OtpCode
from ..schemas import SendOtpRequest, VerifyOtpRequest, TokenResponse, UserResponse, SetupProfileRequest

router = APIRouter()

SECRET_KEY = "arapoint_secret_key_2024"
ALGORITHM = "HS256"


def create_token(user_id: str) -> str:
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + timedelta(days=30),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def generate_otp() -> str:
    return "".join(random.choices(string.digits, k=6))


@router.post("/send-otp")
def send_otp(request: SendOtpRequest, db: Session = Depends(get_db)):
    if not request.phone.startswith("09") or len(request.phone) != 11:
        raise HTTPException(status_code=400, detail="شماره موبایل نامعتبر است")

    code = generate_otp()
    otp = OtpCode(phone=request.phone, code=code)
    db.add(otp)
    db.commit()

    # In production, send SMS. For MVP, print to console:
    print(f"[SMS Mock] Sending OTP {code} to {request.phone}")

    return {"message": "کد تأیید ارسال شد", "phone": request.phone}


@router.post("/verify-otp", response_model=TokenResponse)
def verify_otp(request: VerifyOtpRequest, db: Session = Depends(get_db)):
    otp = (
        db.query(OtpCode)
        .filter(
            OtpCode.phone == request.phone,
            OtpCode.code == request.code,
            OtpCode.is_used == False,
        )
        .order_by(OtpCode.created_at.desc())
        .first()
    )

    # For MVP, also accept "123456" as universal test code
    if otp is None and request.code != "123456":
        raise HTTPException(status_code=400, detail="کد تأیید نامعتبر است")

    if otp:
        otp.is_used = True
        db.commit()

    user = db.query(User).filter(User.phone == request.phone).first()
    if not user:
        user = User(phone=request.phone, full_name="کاربر جدید")
        db.add(user)
        db.commit()
        db.refresh(user)

    token = create_token(user.id)
    return TokenResponse(
        access_token=token,
        user=UserResponse.from_orm(user),
    )


@router.get("/me", response_model=UserResponse)
def get_me(db: Session = Depends(get_db)):
    # Simplified - in real app would validate JWT Bearer token
    user = db.query(User).first()
    if not user:
        raise HTTPException(status_code=401, detail="احراز هویت الزامی است")
    return user
