# Student Management App - Features Documentation

## 📱 Application Overview
**MahSkul** is a comprehensive Flutter mobile application for managing students (Sinh viên) and departments (Ngành học) with modern features including authentication, camera integration, geocoding, maps, and contacts import.

## ✨ Completed Features

### 1️⃣ Authentication System (T8)
- **User Registration**: Create account with username, password, and optional student ID link
- **User Login**: Secure login with SHA-256 password hashing
- **Session Management**: Persistent login state using shared_preferences
- **Account Deletion**: Remove accounts when deleting linked students
- **Password Security**: Industry-standard SHA-256 hashing via crypto package

**Files:**
- `lib/src/ui/features/auth/login_page.dart`
- `lib/src/ui/features/auth/register_page.dart`
- `lib/src/data/repositories/auth_repository.dart`

---

### 2️⃣ Student Management (T5, T6)

#### Student List Page (T5)
- **Display All Students**: Card-based list with avatar, name, student ID, department
- **Search Functionality**: Filter by name or student ID (real-time)
- **Empty State**: User-friendly message when no students exist
- **Navigation**: Tap to view details, FAB to create new student
- **Delete Confirmation**: Alert dialog before deletion
- **Pull-to-Refresh**: Swipe down to reload data

#### Student Detail Page (T5)
- **Complete Profile Display**: All fields including avatar, personal info, GPS coordinates
- **Department Information**: Shows linked ngành học
- **Quick Actions**: 
  - Edit button (navigates to edit form)
  - Delete button (with confirmation)
  - Map button (opens Google Maps if coordinates available)
- **Avatar Display**: Shows student photo or default icon
- **Information Cards**: Organized sections for personal, academic, and location data

#### Student Create/Update Form (T6)
- **Required Fields**: Student ID (maSV), Full name (hoTen)
- **Optional Fields**: Birth date, email, phone, address, department
- **Avatar Picker**: 
  - Take photo with camera
  - Select from gallery
  - Image saved to app documents directory
- **Geocoding Integration**: 
  - "Xác định tọa độ" button next to address field
  - Converts address to GPS coordinates (lat/lng)
  - Shows coordinates below address field
- **Department Dropdown**: Select from available ngành học
- **Validation**: 
  - Email format validation
  - Required field checks
  - Student ID uniqueness (enforced by database)
- **Immutable Fields**: Can't edit student ID (maSV) when updating
- **Contacts Import**: **NEW!** "Nhập từ danh bạ" button imports name, phone, email from phone contacts

**Files:**
- `lib/src/ui/features/sinhvien/list/sinhvien_list_page.dart`
- `lib/src/ui/features/sinhvien/detail/sinhvien_detail_page.dart`
- `lib/src/ui/features/sinhvien/edit/sinhvien_edit_page.dart`
- `lib/src/data/repositories/sinhvien_repository.dart`

---

### 3️⃣ Department Management (T7)

#### Department List Page
- **Display All Departments**: Card-based list with icon, code, name, description
- **CRUD Operations**: Create, Read, Update, Delete via popup menu
- **Delete Confirmation**: Alert dialog with warning about student impact
- **Empty State**: Helpful message when no departments exist
- **Navigation**: FAB to create new department
- **Refresh**: Pull-to-refresh or invalidate provider

#### Department Edit Page
- **Three Fields**:
  - Code (ma): Required, unique, immutable after creation
  - Name (ten): Required
  - Description (moTa): Optional, multi-line
- **Validation**: Required field checks, uniqueness enforcement
- **Create/Update Mode**: Single form handles both operations
- **Timestamps**: Auto-managed createdAt/updatedAt

**Files:**
- `lib/src/ui/features/nganh/list/nganh_list_page.dart`
- `lib/src/ui/features/nganh/edit/nganh_edit_page.dart`
- `lib/src/data/repositories/nganh_repository.dart`

---

### 4️⃣ Google Maps Integration (T10)

#### Map Page
- **Google Maps Display**: Full-screen interactive map
- **Student Location Marker**: Red marker with custom InfoWindow
- **Marker Info**: Shows student name and address
- **Initial Position**: Defaults to Hanoi (21.0285, 105.8542) if no coordinates
- **Navigation Controls**: 
  - My Location button
  - Zoom controls
  - FAB to recenter on marker
- **External Maps**: Button to open location in Google Maps app (via url_launcher)
- **Info Card**: Bottom sheet showing name, address, coordinates

**Files:**
- `lib/src/ui/features/map/map_page.dart`
- `lib/src/data/repositories/geocode_repository.dart`

**Packages:**
- `google_maps_flutter: ^2.9.0`
- `geocoding: ^2.2.0`
- `url_launcher: ^6.3.0`

---

### 5️⃣ Contacts Import (T9) **NEW!**

#### Contact Picker Dialog
- **Permission Handling**: Requests READ_CONTACTS permission at runtime
- **Contact List Display**: Alphabetically sorted with avatar circles
- **Search Functionality**: Filter by name or phone number (real-time)
- **Contact Details**: Shows primary phone, email, and count of additional numbers
- **Multi-Number/Email Support**: Secondary dialog to choose specific phone/email if multiple exist
- **Error Handling**: 
  - Permission denied message with "Open Settings" button
  - Empty state for no contacts
  - No results state for search
- **Material 3 Design**: Cards, proper spacing, icons

#### Integration with Student Form
- **Import Button**: "Nhập từ danh bạ" button between birth date and email fields
- **Auto-Fill Logic**:
  - Name: Only fills if current name field is empty
  - Phone: Always overwrites with selected contact's phone
  - Email: Always overwrites with selected contact's email
- **Success Feedback**: SnackBar confirmation "Đã nhập thông tin từ danh bạ"

**Files:**
- `lib/src/ui/features/sinhvien/widgets/contact_picker_dialog.dart`
- `android/app/src/main/AndroidManifest.xml` (READ_CONTACTS permission)

**Package:**
- `flutter_contacts: ^1.1.7`

---

### 6️⃣ Database Report Page (T11)

#### Report Dashboard
- **Statistics Cards**: Real-time counts for:
  - Sinh viên (Students) - Blue icon
  - Ngành học (Departments) - Green icon
  - Tài khoản (Accounts) - Orange icon
  - Tổng bảng (Total Tables) - Purple icon
- **Database Schema Documentation**:
  - **Nganh Table**: 6 fields (id, ma, ten, moTa, timestamps)
  - **SinhVien Table**: 13 fields including GPS, avatar, foreign keys
  - **Account Table**: 5 fields with password hash, foreign key
- **Relationships Visualization**:
  - SinhVien.nganhId → Nganh.id (Many-to-One)
  - Account.sinhVienId → SinhVien.id (One-to-One)
- **Refresh Options**: Pull-to-refresh or AppBar refresh button
- **Field Details**: Data types, constraints, descriptions in Vietnamese

**Files:**
- `lib/src/ui/features/report/report_page.dart`
- `lib/src/data/repositories/auth_repository.dart` (added getAllAccounts method)

---

### 7️⃣ Navigation & Routing (T4)

#### Go Router Configuration
- **Route Guards**: Authentication-based redirects
- **Deep Linking**: Support for external navigation
- **Named Routes**: Easy navigation throughout app
- **Route Paths**:
  - `/login` - Login page
  - `/register` - Registration page
  - `/` - Student list (protected)
  - `/student/:id` - Student detail
  - `/student/edit/:id?` - Create/edit student
  - `/nganh` - Department list
  - `/nganh/edit/:id?` - Create/edit department
  - `/map/:id` - Map view for student
  - `/report` - Database report

**Files:**
- `lib/src/ui/app_router.dart`

---

### 8️⃣ Database & Data Layer (T2, T3)

#### SQLite Database
- **Three Tables**: Account, Nganh, SinhVien
- **Foreign Keys**: Properly enforced relationships
- **Timestamps**: Auto-managed creation and update times
- **Sample Data**: Seeded with 5 departments and 5 students

#### DAOs (Data Access Objects)
- **AccountDao**: CRUD + username/sinhVienId lookups
- **NganhDao**: CRUD + unique code validation
- **SinhVienDao**: CRUD + student ID lookups, join queries

#### Repositories
- **Pattern**: Sealed Result<T> type (Success/Failure)
- **Error Handling**: Comprehensive try-catch with logging
- **Domain Methods**: Business-logic-friendly APIs
- **Media Repository**: Camera and gallery image handling
- **Geocoding Repository**: Address to coordinates conversion

**Files:**
- `lib/src/data/db/app_database.dart`
- `lib/src/data/db/dao/*.dart`
- `lib/src/data/repositories/*.dart`
- `lib/src/common/result.dart`

---

### 9️⃣ UI/UX & Theming (T1)

#### Material 3 Design
- **Dynamic Color**: Adapts to system color scheme
- **Theme Toggle**: Switch between light and dark modes
- **Card Design**: Consistent elevated cards throughout
- **Icons**: Material Icons for all actions
- **Spacing**: 8px grid system
- **Typography**: Material 3 text styles

#### State Management
- **Riverpod**: FutureProvider, StateProvider, ConsumerWidget pattern
- **Async Handling**: Loading, error, and success states
- **Provider Invalidation**: Refresh data after mutations
- **Auto-dispose**: Memory management with .autoDispose

**Files:**
- `lib/src/common/app_theme.dart`
- `lib/src/ui/app.dart`

---

## 📦 Dependencies

```yaml
dependencies:
  # State management
  flutter_riverpod: ^2.5.0
  
  # Navigation
  go_router: ^14.2.0
  
  # Database
  sqflite: ^2.3.3
  path_provider: ^2.1.4
  
  # Media
  image_picker: ^1.1.2
  
  # Permissions
  permission_handler: ^11.3.1
  
  # Maps & Location
  google_maps_flutter: ^2.9.0
  geocoding: ^2.2.0
  url_launcher: ^6.3.0
  
  # Contacts
  flutter_contacts: ^1.1.7
  
  # Utilities
  intl: ^0.19.0
  shared_preferences: ^2.3.2
  crypto: ^3.0.5
```

---

## 🔐 Permissions (Android)

Configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

---

## 🏗️ Architecture

### MVVM Pattern
- **Models**: Data classes with fromMap/toMap (lib/src/data/models)
- **Views**: Stateful/Stateless widgets (lib/src/ui/features)
- **ViewModels**: Riverpod providers (inline in pages)
- **Repositories**: Business logic layer (lib/src/data/repositories)

### Project Structure
```
lib/
├── src/
│   ├── common/           # Shared utilities (Result, Logger, Theme)
│   ├── data/
│   │   ├── db/          # Database and DAOs
│   │   ├── models/      # Data models
│   │   └── repositories/# Data access layer
│   └── ui/
│       ├── features/    # Feature pages
│       │   ├── auth/
│       │   ├── sinhvien/
│       │   ├── nganh/
│       │   ├── map/
│       │   └── report/
│       ├── app.dart     # Root widget
│       └── app_router.dart
└── main.dart
```

---

## 🎯 Original Requirements Fulfillment

All requirements from the Vietnamese specification have been completed:

✅ **Quản lý Sinh viên**: Full CRUD with camera, geocoding  
✅ **Quản lý Ngành học**: Full CRUD with validation  
✅ **Đăng ký/Đăng nhập**: SHA-256 authentication  
✅ **Chụp ảnh**: Camera and gallery integration  
✅ **Xác định vị trí trên Google Maps**: Maps with markers and navigation  
✅ **Đọc danh bạ điện thoại**: Contacts picker with import  
✅ **Database Report**: Schema and statistics page  

---

## 🚀 How to Run

1. **Prerequisites**:
   - Flutter SDK 3.9.2 or higher
   - Android Studio with emulator
   - VS Code with Flutter extension

2. **Setup**:
   ```bash
   flutter pub get
   ```

3. **Run**:
   ```bash
   flutter run -d emulator-5554
   ```

4. **Test Account**:
   - Username: `admin`
   - Password: `admin123`
   - (or register a new account)

---

## 📸 Key Features Demo Flow

1. **Register/Login** → Create account or login
2. **View Students** → See list of students with search
3. **Create Student** → Use camera, import from contacts, geocode address
4. **View on Map** → See student location with marker
5. **Manage Departments** → CRUD operations for ngành học
6. **View Report** → See database statistics and schema

---

## 🛠️ Technical Highlights

- **Sealed Result Type**: Type-safe error handling
- **Pattern Matching**: Modern Dart 3 switch expressions
- **Provider Invalidation**: Proper state refresh after mutations
- **Permission Handling**: Runtime permission requests with rationale
- **Image Management**: Saved to app documents directory
- **GPS Coordinates**: Geocoding with error handling
- **Foreign Key Constraints**: Database integrity enforcement
- **Material 3**: Modern, adaptive UI design

---

## 📝 Future Enhancements (Optional)

- [ ] Export student data to CSV/Excel
- [ ] Bulk import students from file
- [ ] Advanced search filters (by department, date range)
- [ ] Student attendance tracking
- [ ] Grade management system
- [ ] Push notifications
- [ ] Cloud sync with Firebase
- [ ] Offline mode with sync queue

---

**Version**: 1.0.0  
**Last Updated**: October 20, 2025  
**Status**: ✅ All core features complete
