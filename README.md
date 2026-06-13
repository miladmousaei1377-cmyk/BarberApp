# آراپوینت (AraPoint) — Salon Appointment Booking App

A complete Flutter Android application for salon appointment booking in Persian (RTL), targeting the Iranian market.

## Features

- 🗓️ **Booking Flow**: 3-step booking (service → date/time → confirm)
- 🔐 **Auth**: Phone + OTP verification
- 🏪 **Salons**: Browse, filter, search salons with categories
- 📅 **Jalali Calendar**: Native Shamsi date picker
- 🗺️ **Map**: View salon locations on OpenStreetMap
- 👤 **Profile**: Edit profile, view appointments
- 🏢 **Owner Panel**: Daily/weekly appointments & revenue stats
- 💰 **Persian Numbers**: Full Farsi numeral formatting
- 🌙 **RTL**: Complete right-to-left layout

## Tech Stack

- **Flutter 3.x** + **GetX** (state management)
- **Shamsi Date** (Jalali calendar)
- **Vazirmatn** font (Persian typography)
- **FastAPI** backend (Python)
- **SQLAlchemy** + SQLite/PostgreSQL

## Setup

### Flutter App

1. Install Flutter 3.x from [flutter.dev](https://flutter.dev)

2. Download Vazirmatn fonts:
   ```
   https://github.com/rastikerdar/vazirmatn/releases
   ```
   Place `.ttf` files in `assets/fonts/`

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run on Android:
   ```bash
   flutter run
   ```

### Backend (FastAPI)

```bash
cd backend
pip install -r requirements.txt
python -m backend.seed  # Seed with mock data
uvicorn backend.main:app --reload
```

API available at `http://localhost:8000`
Docs at `http://localhost:8000/docs`

## App Structure

```
lib/
├── main.dart                    # App entry point
├── app/
│   ├── routes/app_pages.dart    # Navigation routes
│   └── theme/app_theme.dart     # Design system / colors
├── core/
│   ├── network/dio_client.dart  # HTTP client
│   ├── storage/storage_service.dart  # Local storage
│   └── utils/persian_utils.dart # Persian number/date utils
├── data/
│   ├── models/                  # Data models
│   ├── repositories/            # Data layer
│   └── mock/mock_data.dart      # Mock data (MVP)
└── presentation/
    ├── screens/                 # All app screens
    └── widgets/                 # Reusable widgets
```

## Screens

| Screen | Description |
|--------|-------------|
| Splash + Onboarding | Animated logo + 3 feature slides |
| Phone Auth | Iranian phone number input |
| OTP Verify | 6-digit code with auto-focus |
| Profile Setup | Name + avatar |
| Home | Search, categories, nearby & top salons |
| Salon List | Filterable list with sort options |
| Salon Detail | Services, stylists, reviews, info tabs |
| Booking Step 1 | Service & stylist selection |
| Booking Step 2 | Jalali calendar + time slots |
| Booking Step 3 | Summary + confirmation |
| Booking Success | Animated success screen |
| Appointments | Upcoming/past/cancelled tabs |
| Map | Salon markers with preview |
| Profile | User info, settings, logout |
| Owner Panel | Daily/weekly view + stats |

## Design System

```dart
primary:    Color(0xFF1A1A2E)  // Deep navy
secondary:  Color(0xFFE94560)  // Vibrant red/pink
gold:       Color(0xFFFFD700)  // Star ratings
background: Color(0xFFF8F9FA)  // Light gray
success:    Color(0xFF28A745)  // Available slots
```

## Mock Data

5 salons across Tehran with realistic data:
- آرایشگاه مدرن (مردانه) - ولیعصر - ⭐ 4.8
- سالن زیبایی لاله (زنانه) - انقلاب - ⭐ 4.6
- باربر شاپ کلاسیک (مردانه) - آزادی - ⭐ 4.5
- سالن آریا (یونیسکس) - شریعتی - ⭐ 4.7
- آرایشگاه رویال (مردانه) - نیاوران - ⭐ 4.9
