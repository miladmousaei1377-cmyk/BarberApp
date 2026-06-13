from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from .routers import auth, salons, appointments, reviews
from .database import engine, Base

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="BarberBook API",
    description="آراپوینت - سیستم رزرو نوبت آرایشگاه",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/auth", tags=["Auth"])
app.include_router(salons.router, prefix="/api/salons", tags=["Salons"])
app.include_router(appointments.router, prefix="/api/appointments", tags=["Appointments"])
app.include_router(reviews.router, prefix="/api/reviews", tags=["Reviews"])


@app.get("/")
def root():
    return {"message": "آراپوینت API", "status": "running"}


if __name__ == "__main__":
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
