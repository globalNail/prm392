# GitHub Copilot — Task Plan Prompt (Flutter MVVM Student/Nganh App)

> **Flutter developer expert.** Read this file and generate code and files to implement the described mobile app using **Flutter** with an **MVVM** architecture. Follow the structure, naming, and acceptance criteria below. Prefer clean, testable code and small, composable units. When unclear, choose sensible defaults and document inline.

---

## 0) Tech & Constraints
- **Framework:** Flutter (stable channel), Material 3, Dark/Light theme.
- **Architecture:** MVVM + Repository.
- **State mgmt:** Riverpod (prefer) or Provider (if simpler). Use immutable models.
- **Local DB:** SQLite via `sqflite` + `path_provider`.
- **Camera/Photos:** `image_picker` (or `camera` if needed for live preview).
- **Permissions:** `permission_handler`.
- **Maps & Geocoding:** `google_maps_flutter`, `geocoding`.
- **Contacts:** `flutter_contacts` (read-only import to app).
- **Auth (local):** Simple local auth with SQLite (account table) for Register/Login.
- **Navigation:** `go_router`.
- **Linting/format:** `flutter_lints` + `very_good_analysis` (optional) with fixed issues.

> Add to `pubspec.yaml`:
```
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  go_router: ^14.2.0
  sqflite: ^2.3.3
  path_provider: ^2.1.4
  image_picker: ^1.1.2
  permission_handler: ^11.3.1
  google_maps_flutter: ^2.9.0
  geocoding: ^2.2.0
  flutter_contacts: ^1.1.7
  intl: ^0.19.0

dev_dependencies:
  flutter_lints: ^4.0.0
  build_runner: ^2.4.12
```

> **Android/iOS setup**
- Android `minSdkVersion >= 21`. Add required uses-permission for CAMERA, READ_CONTACTS, ACCESS_FINE_LOCATION, INTERNET, ACCESS_COARSE_LOCATION. Request runtime permissions with `permission_handler`.
- iOS `Info.plist`: NSCameraUsageDescription, NSPhotoLibraryAddUsageDescription, NSContactsUsageDescription, NSLocationWhenInUseUsageDescription, NSLocationAlwaysAndWhenInUseUsageDescription, NSLocationAlwaysUsageDescription.
- Google Maps API key injected via native configs and passed to Flutter.

---

## 1) Domain Model
**Tables / Entities** (SQLite)
- `Nganh` — { `id` INTEGER PK, `ma` TEXT UNIQUE NOT NULL, `ten` TEXT NOT NULL, `moTa` TEXT NULL, `createdAt` INTEGER, `updatedAt` INTEGER }
- `SinhVien` — { `id` INTEGER PK, `maSV` TEXT UNIQUE NOT NULL, `hoTen` TEXT NOT NULL, `ngaySinh` TEXT NULL ISO8601, `diaChi` TEXT NULL, `sdt` TEXT NULL, `email` TEXT NULL, `nganhId` INTEGER FK -> Nganh(id) ON DELETE SET NULL, `avatarPath` TEXT NULL, `lat` REAL NULL, `lng` REAL NULL, `createdAt` INTEGER, `updatedAt` INTEGER }
- `Account` — { `id` INTEGER PK, `username` TEXT UNIQUE NOT NULL, `passwordHash` TEXT NOT NULL, `sinhVienId` INTEGER UNIQUE FK -> SinhVien(id) ON DELETE CASCADE, `createdAt` INTEGER }

> **Note:** Keep schema versioned with a simple `migrations` table; provide `onCreate/onUpgrade` DDL.

**Core use cases**
1. List students (names) from SQLite.
2. Tap a student ➜ navigate to Student Detail page.
3. CRUD: `SinhVien` and `Nganh`.
4. Capture/choose photo ➜ update `avatarPath` of student.
5. Register account + Login ➜ navigate to Student Info area.
6. Delete student account.
7. Geocode `diaChi` ➜ resolve `(lat,lng)` ➜ show marker on Google Map.
8. Read phone contacts ➜ allow user to select numbers/emails to save into a student profile.
9. Aesthetic, modern UI (Material 3), responsive layouts.
10. Include **Report screen**: Database description & schema overview.

---

## 2) Project Structure (enforce foldering/names)
```
lib/
  src/
    common/
      app_logger.dart
      app_router.dart
      app_theme.dart
      result.dart                 // sealed-like success/failure wrapper
    data/
      db/
        app_database.dart         // open DB, migrations
        dao/
          sinhvien_dao.dart
          nganh_dao.dart
          account_dao.dart
      models/
        sinhvien.dart
        nganh.dart
        account.dart
      repositories/
        sinhvien_repository.dart
        nganh_repository.dart
        auth_repository.dart
        geocode_repository.dart
        contacts_repository.dart
        media_repository.dart
    domain/
      services/
        auth_service.dart
        student_service.dart
        nganh_service.dart
      validators/
        auth_validators.dart
        student_validators.dart
    ui/
      features/
        auth/
          login_vm.dart
          login_page.dart
          register_vm.dart
          register_page.dart
        sinhvien/
          list/
            sinhvien_list_vm.dart
            sinhvien_list_page.dart
          detail/
            sinhvien_detail_vm.dart
            sinhvien_detail_page.dart
          edit/
            sinhvien_edit_vm.dart
            sinhvien_edit_page.dart
        nganh/
          list/
            nganh_list_vm.dart
            nganh_list_page.dart
          edit/
            nganh_edit_vm.dart
            nganh_edit_page.dart
        map/
          map_vm.dart
          map_page.dart
        report/
          report_vm.dart
          report_page.dart
      widgets/
        avatar_picker.dart
        form_fields.dart
        empty_state.dart
        error_retry.dart
    main.dart
```

**MVVM rules**
- **ViewModel**: owns state (immutable), exposes `AsyncValue<T>` via Riverpod, no context.
- **View**: StatelessWidgets, subscribes to providers, triggers intents.
- **Repository/Service**: I/O logic, DB, platform channels.

---

## 3) Database DDL (for `onCreate`)
```sql
CREATE TABLE IF NOT EXISTS Nganh (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ma TEXT NOT NULL UNIQUE,
  ten TEXT NOT NULL,
  moTa TEXT,
  createdAt INTEGER,
  updatedAt INTEGER
);

CREATE TABLE IF NOT EXISTS SinhVien (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maSV TEXT NOT NULL UNIQUE,
  hoTen TEXT NOT NULL,
  ngaySinh TEXT,
  diaChi TEXT,
  sdt TEXT,
  email TEXT,
  nganhId INTEGER,
  avatarPath TEXT,
  lat REAL,
  lng REAL,
  createdAt INTEGER,
  updatedAt INTEGER,
  FOREIGN KEY(nganhId) REFERENCES Nganh(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Account (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  passwordHash TEXT NOT NULL,
  sinhVienId INTEGER UNIQUE,
  createdAt INTEGER,
  FOREIGN KEY(sinhVienId) REFERENCES SinhVien(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS _Migrations (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  appliedAt INTEGER NOT NULL
);
```

---

## 4) Tasks for Copilot (deliver end‑to‑end)

### T1 — Bootstrap & Theming
- Create project, add dependencies, configure Material 3 theming, typography, color scheme.
- Implement `AppTheme` with dynamic color support and theme toggling (persisted in `SharedPreferences`).
- **Acceptance:** App builds & toggles theme; lints passing.

### T2 — SQLite Setup & DAOs
- Implement `AppDatabase` (open DB in app docs dir, version, migrations).
- Write DAOs for `Nganh`, `SinhVien`, `Account` with CRUD and reactive streams for lists.
- Seed sample data for demo.
- **Acceptance:** Unit tests insert/list/update/delete for each DAO.

### T3 — Repositories & Services
- `sinhvien_repository.dart`, `nganh_repository.dart`, `auth_repository.dart` with domain-friendly methods.
- `student_service.dart`, `nganh_service.dart`, `auth_service.dart` composing repositories and validators.
- **Acceptance:** Repository tests with in-memory DB.

### T4 — Navigation (go_router)
- Define routes: `/`, `/login`, `/register`, `/sv`, `/sv/:id`, `/sv/:id/edit`, `/nganh`, `/nganh/:id/edit`, `/map`, `/report`.
- Guard: unauthenticated ➜ redirect to `/login` (except `/register`).
- **Acceptance:** Deep linking to `/sv/:id` opens detail.

### T5 — UI: Student List & Detail
- **List Page:** Show list of students (name + avatar). FAB ➜ create. Search by name/maSV.
- **Detail Page:** Show all fields, `Edit`, `Delete`, `Open on Map`, `Import Contacts`.
- **Acceptance:** Tapping a student opens detail; delete returns to list with refresh.

### T6 — UI: Create/Update Student
- Form with validation (required: `hoTen`, `maSV`; optional others). Picker for `Nganh`.
- Avatar widget uses `image_picker` (`camera` or `gallery`), saves file to app storage and stores path in DB.
- **Acceptance:** Create & update persist; avatar shown in list/detail.

### T7 — UI: Nganh CRUD
- `Nganh` list + create/update pages (fields: `ma`, `ten`, `moTa`).
- Prevent duplicate `ma` with unique validation.
- **Acceptance:** Editing a Nganh updates linked Student display via JOIN.

### T8 — Auth: Register/Login & Delete Account
- Register page: username, password (confirm), **link** to existing `SinhVien` by `maSV` (selectable).
- Login page: username/password ➜ on success navigate to student info (`/sv/:id`).
- Delete account action inside detail (if linked), with confirmation dialog.
- Password: hash via `crypto` (SHA-256 + salt stored alongside; simple for demo).
- **Acceptance:** Cannot register duplicate username; delete cascades if `sinhVienId` removed.

### T9 — Contacts Import
- Request contacts permission; show searchable list of phone contacts.
- Allow user to pick a contact ➜ update `sdt`/`email` fields.
- **Acceptance:** Selected contact values saved on student.

### T10 — Maps & Geocoding
- Forward-geocode `diaChi` ➜ save `(lat,lng)` in DB. Map shows marker; button to open external map intent.
- **Acceptance:** Invalid address shows error + retry; valid address pins correctly.

### T11 — Report Page (Database Description)
- Render a human-readable description of the database (entities, fields, relationships) and current counts per table.
- Include ER-style diagram (ASCII or simple widget) and last migration name/date.
- **Acceptance:** Page loads offline and reflects live DB counts.

### T12 — Permissions & Error UX
- Centralize permission requests with rationale dialogs.
- Reusable `ErrorRetry` and empty states.
- **Acceptance:** No silent failures; user sees actionable messages.

### T13 — Testing & CI-ready
- Unit tests for DAOs, repositories, validators.
- Golden tests for key widgets (list, forms) if feasible.
- **Acceptance:** `flutter test` passes.

---

## 5) ViewModels — Intents & States (examples)
- `SinhVienListVm`: intents `load()`, `search(String)`, `delete(int id)`; state `AsyncValue<List<SinhVien>>` + query.
- `SinhVienDetailVm`: `load(id)`, `delete()`, `toMap()`, `importContact()`, `updateAvatar(XFile)`.
- `SinhVienEditVm`: form state + `save()`; validation errors exposed per-field.
- `NganhEditVm`: `save()`, unique `ma` check.
- `LoginVm`: `login(u,p)`; `RegisterVm`: `register(u,p,maSV)`.
- `MapVm`: `geocode(address)`, `openExternalMap(lat,lng)`.

---

## 6) UI/UX & Aesthetic Checklist
- Material 3, coherent color system, rounded corners, elevation, proper spacing.
- Adaptive layouts; large tap targets; pull-to-refresh on lists.
- Form validation messages; loading indicators; snackbars for success.
- Accessible labels; contrast; dynamic text sizes.

---

## 7) Developer Experience
- Add `make` or `justfile` tasks: `bootstrap`, `lint`, `test`, `run`.
- Preconfigure `analysis_options.yaml` with rules; fix warnings.
- Add `README.md` with setup (API keys, permissions, run instructions).

---

## 8) Acceptance Demo Script (for 5–10 min)
1. Launch app → login redirect.
2. Register new account linked to existing `SinhVien`.
3. Show student list; create new student (+ avatar via camera); open detail.
4. Edit address → geocode → view on map.
5. Import a phone contact to fill phone/email.
6. CRUD `Nganh` and show effect on student.
7. Open Report page to show DB description.

---

## 9) Definition of Done (DoD)
- All tasks T1–T13 complete with passing tests.
- No analyzer warnings; basic offline support for list/detail.
- README updated; demo script reproducible.

---

## 10) Notes to Copilot
- Prefer composition over inheritance; small files; pure functions where possible.
- Keep platform-conditional code in services; mock I/O in tests.
- Write doc comments for public classes/methods.
- If a plugin is not available, scaffold interfaces so we can swap later.

