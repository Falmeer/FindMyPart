# FindMyPart — Automotive Marketplace & Service Platform

A production-quality full-stack mobile application built as a university senior project. Connects customers, salvage yards, spare parts sellers, and car garages into one centralized automotive ecosystem.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter 3 · Dart · Riverpod · go_router |
| Backend API | Laravel 11 · PHP 8.2 · REST API |
| Database | MySQL 8 |
| Authentication | Laravel Sanctum (token-based) |
| Maps | Google Maps Flutter |
| Images | Cached Network Image · Image Picker |

---

## Project Structure

```
FindMyPart/
├── frontend/          # Flutter mobile app
│   ├── lib/
│   │   ├── core/            # Theme, router, constants, network, errors
│   │   ├── shared/          # Reusable widgets
│   │   ├── features/
│   │   │   ├── auth/        # Login, register, forgot password
│   │   │   ├── home/        # Dashboard, banners, categories
│   │   │   ├── salvaged_vehicles/
│   │   │   ├── spare_parts/
│   │   │   ├── garages/     # Garage listings, issue posting
│   │   │   ├── chat/        # Messaging system
│   │   │   ├── favorites/
│   │   │   ├── profile/
│   │   │   └── notifications/
│   │   └── main.dart
│   └── pubspec.yaml
│
└── backend/           # Laravel REST API
    ├── app/
    │   ├── Http/
    │   │   ├── Controllers/API/V1/
    │   │   ├── Requests/
    │   │   └── Resources/
    │   └── Models/
    ├── database/
    │   ├── migrations/
    │   └── seeders/
    └── routes/api.php
```

---

## User Roles

| Role | Capabilities |
|---|---|
| `customer` | Browse, search, favorite, post issues, chat |
| `garage` | Create garage profile, manage parts, respond to issues |
| `yard_owner` | List salvaged vehicles, manage inventory |
| `admin` | Full platform access |

---

## API Endpoints

### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout          [auth]
GET    /api/v1/auth/me              [auth]
POST   /api/v1/auth/forgot-password
```

### Salvaged Vehicles
```
GET    /api/v1/vehicles             ?search=&brand=&model=&year_from=&year_to=&condition=
GET    /api/v1/vehicles/{id}
POST   /api/v1/vehicles             [auth] multipart/form-data
PUT    /api/v1/vehicles/{id}        [auth]
DELETE /api/v1/vehicles/{id}        [auth]
```

### Spare Parts
```
GET    /api/v1/spare-parts          ?search=&category=&condition=&min_price=&max_price=
GET    /api/v1/spare-parts/{id}
POST   /api/v1/spare-parts          [auth]
PUT    /api/v1/spare-parts/{id}     [auth]
DELETE /api/v1/spare-parts/{id}     [auth]
```

### Garages
```
GET    /api/v1/garages              ?search=&lat=&lng=&radius=
GET    /api/v1/garages/{id}
POST   /api/v1/garages              [auth]
GET    /api/v1/garages/{id}/reviews
POST   /api/v1/garages/{id}/reviews [auth]
```

### Vehicle Issues
```
GET    /api/v1/vehicle-issues                      [auth]
POST   /api/v1/vehicle-issues                      [auth]
GET    /api/v1/vehicle-issues/{id}                 [auth]
POST   /api/v1/vehicle-issues/{id}/offers          [auth — garage only]
```

### Other
```
GET    /api/v1/favorites            [auth]
POST   /api/v1/favorites/toggle     [auth]
GET    /api/v1/conversations        [auth]
POST   /api/v1/conversations        [auth]
GET    /api/v1/conversations/{id}/messages  [auth]
POST   /api/v1/conversations/{id}/messages  [auth]
```

---

## Setup

### Backend (Laravel)

```bash
cd backend
cp .env.example .env

# Install dependencies (requires PHP 8.2+, Composer)
composer install

# Generate app key
php artisan key:generate

# Configure MySQL in .env
# DB_DATABASE=findmypart
# DB_USERNAME=root
# DB_PASSWORD=your_password

# Run migrations and seed data
php artisan migrate --seed

# Start server
php artisan serve
```

### Frontend (Flutter)

```bash
cd frontend

# Install dependencies
flutter pub get

# Update API base URL in lib/core/constants/app_constants.dart
# baseUrl: 'http://10.0.2.2:8000/api/v1'  (Android emulator)
# baseUrl: 'http://localhost:8000/api/v1'  (iOS simulator)

# Run app
flutter run
```

---

## Demo Credentials

| Role | Email | Password |
|---|---|---|
| Admin | admin@findmypart.com | password |
| Customer | customer@demo.com | password |
| Garage Owner | garage@demo.com | password |
| Yard Owner | yard@demo.com | password |

---

## API Response Format

```json
{
  "success": true,
  "message": "Vehicles fetched successfully",
  "data": [...],
  "pagination": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 72
  }
}
```

---

## Database Schema

14 tables: `users`, `garages`, `categories`, `salvaged_vehicles`, `vehicle_images`, `spare_parts`, `spare_part_images`, `vehicle_issues`, `garage_offers`, `chats`, `chat_user`, `messages`, `favorites`, `reviews`, `notifications`, `personal_access_tokens`

---

## Future Roadmap

- [ ] Arabic language support (i18n)
- [ ] AI-powered part recommendations
- [ ] OCR VIN scanning
- [ ] CSV/Excel inventory bulk upload
- [ ] Payment integration (Mada / STC Pay)
- [ ] Promoted listings / ads
- [ ] Firebase push notifications
- [ ] Real-time chat via WebSockets
