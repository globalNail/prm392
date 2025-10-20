# Student Management App (Quản lý Sinh viên)

A comprehensive Flutter mobile application for managing students (Sinh viên) and departments (Ngành) using MVVM architecture with Riverpod state management.

## Features

✅ **Implemented**

- Material 3 Design with dark/light theme support
- SQLite local database with seed data
- Authentication system (register/login)
- Student (SinhVien) and Department (Nganh) data models
- Image picker for student avatars (camera/gallery)
- Geocoding support for addresses
- Contacts integration
- Navigation with go_router
- Offline-first architecture

🚧 **In Progress**

- Complete UI pages for CRUD operations
- Maps integration with Google Maps
- Contacts import functionality
- Report/database schema viewer

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.9.2)
- Android SDK (minSdkVersion 21) or iOS development environment
- Google Maps API key (for map features)

### Installation

1. Clone the repository
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. **Android Setup:**
   Add required permissions to `android/app/src/main/AndroidManifest.xml`

4. **iOS Setup:**
   Add usage descriptions to `ios/Runner/Info.plist`

5. Run the app:

   ```bash
   flutter run
   ```

## Database Schema

- **Nganh** (Department): id, ma (code), ten (name), moTa (description)
- **SinhVien** (Student): id, maSV, hoTen, ngaySinh, diaChi, sdt, email, nganhId, avatarPath, lat/lng
- **Account**: id, username, passwordHash, sinhVienId

## Architecture

**MVVM Pattern with Riverpod**


- Models: Data classes
- Views: Stateless widgets
- ViewModels: Riverpod providers
- Data Layer: DAO → Repository → Service

## Sample Data

The database is seeded with:

- 5 departments (CNTT, KTPM, KHMT, ATTT, TMDT)
- 5 students (SV001 - SV005)

## License

MIT License
