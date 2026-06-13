from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List

from ..database import get_db
from ..models import Review, Salon
from ..schemas import CreateReviewRequest, ReviewResponse

router = APIRouter()

CURRENT_USER_ID = "demo_user"


@router.post("", response_model=ReviewResponse)
def create_review(request: CreateReviewRequest, db: Session = Depends(get_db)):
    if not 1 <= request.rating <= 5:
        raise HTTPException(status_code=400, detail="امتیاز باید بین ۱ تا ۵ باشد")

    review = Review(
        user_id=CURRENT_USER_ID,
        salon_id=request.salon_id,
        appointment_id=request.appointment_id,
        rating=request.rating,
        comment=request.comment,
    )
    db.add(review)
    db.commit()

    # Update salon rating
    avg = db.query(func.avg(Review.rating)).filter(Review.salon_id == request.salon_id).scalar()
    count = db.query(func.count(Review.id)).filter(Review.salon_id == request.salon_id).scalar()
    salon = db.query(Salon).filter(Salon.id == request.salon_id).first()
    if salon:
        salon.rating = round(avg, 1)
        salon.review_count = count
        db.commit()

    db.refresh(review)
    return review


@router.get("/salons/{salon_id}", response_model=List[ReviewResponse])
def get_salon_reviews(salon_id: str, db: Session = Depends(get_db)):
    return (
        db.query(Review)
        .filter(Review.salon_id == salon_id)
        .order_by(Review.created_at.desc())
        .limit(50)
        .all()
    )
