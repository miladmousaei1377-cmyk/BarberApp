from sqlalchemy import Column, String, Float, Integer, Boolean, DateTime, Text, ForeignKey, Enum, Time
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
import uuid

from .database import Base


def gen_uuid():
    return str(uuid.uuid4())


class SalonCategory(str, enum.Enum):
    male = "male"
    female = "female"
    unisex = "unisex"


class AppointmentStatus(str, enum.Enum):
    pending = "pending"
    confirmed = "confirmed"
    cancelled = "cancelled"
    done = "done"


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=gen_uuid)
    phone = Column(String(11), unique=True, nullable=False, index=True)
    full_name = Column(String(100), nullable=False)
    avatar_url = Column(String, nullable=True)
    created_at = Column(DateTime, server_default=func.now())

    appointments = relationship("Appointment", back_populates="user")
    reviews = relationship("Review", back_populates="user")


class Salon(Base):
    __tablename__ = "salons"

    id = Column(String, primary_key=True, default=gen_uuid)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    address = Column(String(300), nullable=False)
    lat = Column(Float, nullable=False)
    lng = Column(Float, nullable=False)
    cover_image = Column(String, nullable=True)
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    is_verified = Column(Boolean, default=False)
    category = Column(Enum(SalonCategory), nullable=False)
    owner_id = Column(String, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, server_default=func.now())

    stylists = relationship("Stylist", back_populates="salon")
    services = relationship("Service", back_populates="salon")
    appointments = relationship("Appointment", back_populates="salon")
    reviews = relationship("Review", back_populates="salon")


class Stylist(Base):
    __tablename__ = "stylists"

    id = Column(String, primary_key=True, default=gen_uuid)
    salon_id = Column(String, ForeignKey("salons.id"), nullable=False)
    name = Column(String(100), nullable=False)
    avatar = Column(String, nullable=True)
    specialty = Column(String(100), nullable=True)
    rating = Column(Float, default=0.0)

    salon = relationship("Salon", back_populates="stylists")
    working_hours = relationship("WorkingHours", back_populates="stylist")
    appointments = relationship("Appointment", back_populates="stylist")


class Service(Base):
    __tablename__ = "services"

    id = Column(String, primary_key=True, default=gen_uuid)
    salon_id = Column(String, ForeignKey("salons.id"), nullable=False)
    name = Column(String(100), nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    price = Column(Integer, nullable=False)
    category = Column(String(50), nullable=True)

    salon = relationship("Salon", back_populates="services")


class WorkingHours(Base):
    __tablename__ = "working_hours"

    id = Column(String, primary_key=True, default=gen_uuid)
    stylist_id = Column(String, ForeignKey("stylists.id"), nullable=False)
    day_of_week = Column(Integer, nullable=False)  # 0=Saturday ... 6=Friday
    start_time = Column(String(5), nullable=False)
    end_time = Column(String(5), nullable=False)
    is_off = Column(Boolean, default=False)

    stylist = relationship("Stylist", back_populates="working_hours")


class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(String, primary_key=True, default=gen_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    salon_id = Column(String, ForeignKey("salons.id"), nullable=False)
    stylist_id = Column(String, ForeignKey("stylists.id"), nullable=True)
    service_ids = Column(String, nullable=False)  # JSON list
    date = Column(String(10), nullable=False)  # YYYY-MM-DD
    start_time = Column(String(5), nullable=False)
    end_time = Column(String(5), nullable=False)
    status = Column(Enum(AppointmentStatus), default=AppointmentStatus.pending)
    total_price = Column(Integer, nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())

    user = relationship("User", back_populates="appointments")
    salon = relationship("Salon", back_populates="appointments")
    stylist = relationship("Stylist", back_populates="appointments")


class Review(Base):
    __tablename__ = "reviews"

    id = Column(String, primary_key=True, default=gen_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    salon_id = Column(String, ForeignKey("salons.id"), nullable=False)
    appointment_id = Column(String, ForeignKey("appointments.id"), nullable=True)
    rating = Column(Integer, nullable=False)
    comment = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.now())

    user = relationship("User", back_populates="reviews")
    salon = relationship("Salon", back_populates="reviews")


class OtpCode(Base):
    __tablename__ = "otp_codes"

    id = Column(String, primary_key=True, default=gen_uuid)
    phone = Column(String(11), nullable=False, index=True)
    code = Column(String(6), nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    is_used = Column(Boolean, default=False)
