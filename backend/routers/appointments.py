import json
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..models import Appointment, AppointmentStatus, Service
from ..schemas import CreateAppointmentRequest, AppointmentResponse

router = APIRouter()

CURRENT_USER_ID = "demo_user"  # Simplified for MVP


def _calc_end_time(start_time: str, duration_minutes: int) -> str:
    h, m = map(int, start_time.split(":"))
    total = h * 60 + m + duration_minutes
    return f"{total // 60:02d}:{total % 60:02d}"


@router.post("", response_model=AppointmentResponse)
def create_appointment(request: CreateAppointmentRequest, db: Session = Depends(get_db)):
    # Calculate total duration from services
    services = db.query(Service).filter(Service.id.in_(request.service_ids)).all()
    total_duration = sum(s.duration_minutes for s in services)
    end_time = _calc_end_time(request.start_time, total_duration or 30)

    # Check for conflicts
    existing = db.query(Appointment).filter(
        Appointment.salon_id == request.salon_id,
        Appointment.date == request.date,
        Appointment.status.notin_([AppointmentStatus.cancelled]),
    )
    if request.stylist_id:
        existing = existing.filter(Appointment.stylist_id == request.stylist_id)

    def time_to_min(t: str) -> int:
        h, m = map(int, t.split(":"))
        return h * 60 + m

    new_start = time_to_min(request.start_time)
    new_end = time_to_min(end_time)

    for appt in existing.all():
        if not (new_end <= time_to_min(appt.start_time) or new_start >= time_to_min(appt.end_time)):
            raise HTTPException(status_code=409, detail="این زمان قبلاً رزرو شده است")

    appointment = Appointment(
        user_id=CURRENT_USER_ID,
        salon_id=request.salon_id,
        stylist_id=request.stylist_id,
        service_ids=json.dumps(request.service_ids),
        date=request.date,
        start_time=request.start_time,
        end_time=end_time,
        status=AppointmentStatus.confirmed,
        total_price=request.total_price,
        notes=request.notes,
    )
    db.add(appointment)
    db.commit()
    db.refresh(appointment)
    return appointment


@router.get("/my", response_model=List[AppointmentResponse])
def get_my_appointments(db: Session = Depends(get_db)):
    return (
        db.query(Appointment)
        .filter(Appointment.user_id == CURRENT_USER_ID)
        .order_by(Appointment.date.desc(), Appointment.start_time.desc())
        .all()
    )


@router.put("/{appointment_id}/cancel")
def cancel_appointment(appointment_id: str, db: Session = Depends(get_db)):
    appointment = db.query(Appointment).filter(
        Appointment.id == appointment_id,
        Appointment.user_id == CURRENT_USER_ID,
    ).first()

    if not appointment:
        raise HTTPException(status_code=404, detail="رزرو یافت نشد")

    if appointment.status == AppointmentStatus.cancelled:
        raise HTTPException(status_code=400, detail="این رزرو قبلاً لغو شده است")

    appointment.status = AppointmentStatus.cancelled
    db.commit()
    return {"message": "رزرو با موفقیت لغو شد"}
