from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum


class SalonCategory(str, Enum):
    male = "male"
    female = "female"
    unisex = "unisex"


class AppointmentStatus(str, Enum):
    pending = "pending"
    confirmed = "confirmed"
    cancelled = "cancelled"
    done = "done"


# Auth schemas
class SendOtpRequest(BaseModel):
    phone: str


class VerifyOtpRequest(BaseModel):
    phone: str
    code: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: "UserResponse"


class SetupProfileRequest(BaseModel):
    full_name: str


# User schemas
class UserResponse(BaseModel):
    id: str
    phone: str
    full_name: str
    avatar_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# Salon schemas
class StylistResponse(BaseModel):
    id: str
    salon_id: str
    name: str
    avatar: Optional[str] = None
    specialty: Optional[str] = None
    rating: float

    class Config:
        from_attributes = True


class ServiceResponse(BaseModel):
    id: str
    salon_id: str
    name: str
    duration_minutes: int
    price: int
    category: Optional[str] = None

    class Config:
        from_attributes = True


class SalonListResponse(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    address: str
    lat: float
    lng: float
    cover_image: Optional[str] = None
    rating: float
    review_count: int
    is_verified: bool
    category: SalonCategory

    class Config:
        from_attributes = True


class SalonDetailResponse(SalonListResponse):
    services: List[ServiceResponse] = []
    stylists: List[StylistResponse] = []


# Appointment schemas
class CreateAppointmentRequest(BaseModel):
    salon_id: str
    stylist_id: Optional[str] = None
    service_ids: List[str]
    date: str  # YYYY-MM-DD
    start_time: str  # HH:MM
    total_price: int
    notes: Optional[str] = None


class AppointmentResponse(BaseModel):
    id: str
    salon_id: str
    stylist_id: Optional[str] = None
    service_ids: str
    date: str
    start_time: str
    end_time: str
    status: AppointmentStatus
    total_price: int
    notes: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# Review schemas
class CreateReviewRequest(BaseModel):
    salon_id: str
    appointment_id: Optional[str] = None
    rating: int
    comment: str


class ReviewResponse(BaseModel):
    id: str
    user_id: str
    salon_id: str
    rating: int
    comment: str
    created_at: datetime

    class Config:
        from_attributes = True


# Availability
class AvailabilityResponse(BaseModel):
    date: str
    available_slots: List[str]


TokenResponse.model_rebuild()
