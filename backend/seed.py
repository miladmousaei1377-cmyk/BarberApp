"""Seed database with mock data for development."""
from .database import SessionLocal, engine, Base
from .models import Salon, Stylist, Service, WorkingHours, SalonCategory

Base.metadata.create_all(bind=engine)


def seed():
    db = SessionLocal()
    try:
        if db.query(Salon).count() > 0:
            print("Database already seeded.")
            return

        salons_data = [
            {
                "id": "s1",
                "name": "آرایشگاه مدرن",
                "description": "آرایشگاه مدرن با بهترین متخصصین آرایش مردانه",
                "address": "خیابان ولیعصر، نرسیده به چهارراه ولیعصر",
                "lat": 35.7448,
                "lng": 51.4100,
                "rating": 4.8,
                "review_count": 124,
                "is_verified": True,
                "category": SalonCategory.male,
                "owner_id": "owner1",
            },
            {
                "id": "s2",
                "name": "سالن زیبایی لاله",
                "description": "سالن تخصصی خدمات زیبایی بانوان",
                "address": "خیابان انقلاب، روبروی دانشگاه تهران",
                "lat": 35.7001,
                "lng": 51.3877,
                "rating": 4.6,
                "review_count": 89,
                "is_verified": True,
                "category": SalonCategory.female,
                "owner_id": "owner2",
            },
            {
                "id": "s3",
                "name": "باربر شاپ کلاسیک",
                "description": "تجربه‌ای متفاوت از آرایش سنتی مردانه",
                "address": "میدان آزادی، ابتدای خیابان آزادی",
                "lat": 35.6996,
                "lng": 51.3376,
                "rating": 4.5,
                "review_count": 67,
                "is_verified": False,
                "category": SalonCategory.male,
                "owner_id": "owner3",
            },
            {
                "id": "s4",
                "name": "سالن آریا",
                "description": "سالن یونیسکس با امکانات مدرن",
                "address": "خیابان شریعتی، نزدیک پل صدر",
                "lat": 35.7591,
                "lng": 51.4339,
                "rating": 4.7,
                "review_count": 156,
                "is_verified": True,
                "category": SalonCategory.unisex,
                "owner_id": "owner4",
            },
            {
                "id": "s5",
                "name": "آرایشگاه رویال",
                "description": "لوکس‌ترین آرایشگاه مردانه در شمال تهران",
                "address": "نیاوران، خیابان باهنر",
                "lat": 35.8108,
                "lng": 51.4638,
                "rating": 4.9,
                "review_count": 203,
                "is_verified": True,
                "category": SalonCategory.male,
                "owner_id": "owner5",
            },
        ]

        for data in salons_data:
            db.add(Salon(**data))

        services_data = [
            # Salon 1
            {"id": "sv1", "salon_id": "s1", "name": "کوتاهی مو", "duration_minutes": 30, "price": 120000, "category": "hair"},
            {"id": "sv2", "salon_id": "s1", "name": "اصلاح ریش", "duration_minutes": 20, "price": 60000, "category": "beard"},
            {"id": "sv3", "salon_id": "s1", "name": "رنگ مو", "duration_minutes": 90, "price": 280000, "category": "color"},
            {"id": "sv4", "salon_id": "s1", "name": "ماسک مو", "duration_minutes": 30, "price": 120000, "category": "care"},
            {"id": "sv5", "salon_id": "s1", "name": "اصلاح ابرو", "duration_minutes": 15, "price": 30000, "category": "eyebrow"},
            # Salon 2
            {"id": "sv7", "salon_id": "s2", "name": "کوتاهی مو", "duration_minutes": 45, "price": 150000, "category": "hair"},
            {"id": "sv8", "salon_id": "s2", "name": "رنگ مو", "duration_minutes": 120, "price": 450000, "category": "color"},
            {"id": "sv9", "salon_id": "s2", "name": "کراتین", "duration_minutes": 180, "price": 600000, "category": "treatment"},
            # Salon 3
            {"id": "sv13", "salon_id": "s3", "name": "کوتاهی مو", "duration_minutes": 30, "price": 80000, "category": "hair"},
            {"id": "sv14", "salon_id": "s3", "name": "اصلاح ریش", "duration_minutes": 20, "price": 50000, "category": "beard"},
            # Salon 4
            {"id": "sv17", "salon_id": "s4", "name": "کوتاهی مو", "duration_minutes": 40, "price": 130000, "category": "hair"},
            {"id": "sv18", "salon_id": "s4", "name": "اصلاح ریش", "duration_minutes": 20, "price": 70000, "category": "beard"},
            {"id": "sv19", "salon_id": "s4", "name": "رنگ مو", "duration_minutes": 100, "price": 350000, "category": "color"},
            # Salon 5
            {"id": "sv23", "salon_id": "s5", "name": "کوتاهی VIP", "duration_minutes": 45, "price": 150000, "category": "hair"},
            {"id": "sv24", "salon_id": "s5", "name": "اصلاح ریش VIP", "duration_minutes": 30, "price": 80000, "category": "beard"},
        ]

        for data in services_data:
            db.add(Service(**data))

        stylists_data = [
            {"id": "st1", "salon_id": "s1", "name": "علی محمدی", "specialty": "کوتاهی و رنگ مو", "rating": 4.9},
            {"id": "st2", "salon_id": "s1", "name": "رضا احمدی", "specialty": "اصلاح ریش و مو", "rating": 4.7},
            {"id": "st3", "salon_id": "s2", "name": "سارا کریمی", "specialty": "کراتین و رنگ مو", "rating": 4.8},
            {"id": "st4", "salon_id": "s2", "name": "مریم رضایی", "specialty": "کوتاهی و مدل مو", "rating": 4.6},
            {"id": "st5", "salon_id": "s3", "name": "حسین نوری", "specialty": "آرایش کلاسیک", "rating": 4.5},
            {"id": "st6", "salon_id": "s4", "name": "نادر قاسمی", "specialty": "کوتاهی مدرن", "rating": 4.7},
            {"id": "st7", "salon_id": "s4", "name": "فاطمه حسینی", "specialty": "رنگ و هایلایت", "rating": 4.8},
            {"id": "st8", "salon_id": "s5", "name": "محمد صادقی", "specialty": "کوتاهی VIP", "rating": 5.0},
            {"id": "st9", "salon_id": "s5", "name": "امیر حسین‌زاده", "specialty": "اصلاح و مراقبت ریش", "rating": 4.9},
        ]

        for data in stylists_data:
            db.add(Stylist(**data))

        db.commit()
        print("✅ Database seeded successfully!")

    finally:
        db.close()


if __name__ == "__main__":
    seed()
