from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional, List
from datetime import datetime

from ..database import get_db
from ..models import Salon, Stylist, Service, Appointment, AppointmentStatus
from ..schemas import SalonListResponse, SalonDetailResponse, StylistResponse, ServiceResponse, AvailabilityResponse

router = APIRouter()


@router.get("", response_model=List[SalonListResponse])
def list_salons(
    category: Optional[str] = Query(None),
    sort: str = Query("rating"),
    page: int = Query(1),
    db: Session = Depends(get_db),
):
    query = db.query(Salon)

    if category and category in ("male", "female", "unisex"):
        query = query.filter(Salon.category == category)

    if sort == "rating":
        query = query.order_by(Salon.rating.desc())
    elif sort == "reviews":
        query = query.order_by(Salon.review_count.desc())

    offset = (page - 1) * 20
    salons = query.offset(offset).limit(20).all()
    return salons


@router.get("/{salon_id}", response_model=SalonDetailResponse)
def get_salon(salon_id: str, db: Session = Depends(get_db)):
    salon = db.query(Salon).filter(Salon.id == salon_id).first()
    if not salon:
        raise HTTPException(status_code=404, detail="آرایشگاه یافت نشد")

    # Attach related data
    salon.services = db.query(Service).filter(Service.salon_id == salon_id).all()
    salon.stylists = db.query(Stylist).filter(Stylist.salon_id == salon_id).all()
    return salon


@router.get("/{salon_id}/services", response_model=List[ServiceResponse])
def get_services(salon_id: str, db: Session = Depends(get_db)):
    return db.query(Service).filter(Service.salon_id == salon_id).all()


@router.get("/{salon_id}/stylists", response_model=List[StylistResponse])
def get_stylists(salon_id: str, db: Session = Depends(get_db)):
    return db.query(Stylist).filter(Stylist.salon_id == salon_id).all()


@router.get("/{salon_id}/availability", response_model=AvailabilityResponse)
def get_availability(
    salon_id: str,
    date: str = Query(...),
    stylist_id: Optional[str] = Query(None),
    duration: int = Query(30),
    db: Session = Depends(get_db),
):
    try:
        selected_date = datetime.strptime(date, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(status_code=400, detail="فرمت تاریخ نامعتبر است")

    # Iran work week: Sat-Thu 9:00-21:00, Fri 10:00-18:00
    # Python weekday: 0=Monday, 5=Saturday, 4=Friday
    is_friday = selected_date.weekday() == 4
    start_hour = 10 if is_friday else 9
    end_hour = 18 if is_friday else 21

    # Get existing appointments for this date/salon/stylist
    query = db.query(Appointment).filter(
        Appointment.salon_id == salon_id,
        Appointment.date == date,
        Appointment.status.notin_([AppointmentStatus.cancelled]),
    )
    if stylist_id:
        query = query.filter(Appointment.stylist_id == stylist_id)

    existing = query.all()

    def time_to_min(t: str) -> int:
        h, m = map(int, t.split(":"))
        return h * 60 + m

    def min_to_time(m: int) -> str:
        return f"{m // 60:02d}:{m % 60:02d}"

    now = datetime.now()
    slots = []

    for hour in range(start_hour, end_hour):
        for minute in [0, 30]:
            slot_start = hour * 60 + minute
            slot_end = slot_start + duration

            if slot_end > end_hour * 60:
                continue

            # Check if past
            if selected_date == now.date():
                if slot_start <= now.hour * 60 + now.minute:
                    continue

            # Check conflicts
            has_conflict = any(
                not (slot_end <= time_to_min(a.start_time) or slot_start >= time_to_min(a.end_time))
                for a in existing
            )

            if not has_conflict:
                slots.append(min_to_time(slot_start))

    return AvailabilityResponse(date=date, available_slots=slots)
