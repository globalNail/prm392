# Menu & Back Button Refactoring - October 21, 2025

## Overview
Refactored the app's navigation by:
1. **Moving logout to a menu** - Removed from BottomNavigationBar
2. **Adding theme toggle to menu with switch** - Theme toggle moved from AppBar icon button to menu with switch control
3. **Removing back buttons from non-main pages** - Added `automaticallyImplyLeading: false` to detail/edit pages

## Changes Made

### 1. **Main Pages - Menu with Theme & Logout**

All main pages (Student List, Nganh List, Report) now have:
- A **PopupMenuButton** in the AppBar with:
  - Theme toggle with **Switch** control (shows light/dark icon)
  - Logout option with divider
- BottomNavigationBar reduced from 4 to 3 items (removed logout item)

#### File Modified: `sinhvien_list_page.dart`
```dart
// Before: Theme toggle button in AppBar
IconButton(
  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
  onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
),

// After: Menu with theme toggle switch and logout
PopupMenuButton<String>(
  onSelected: (value) {
    switch (value) {
      case 'theme':
        ref.read(themeModeProvider.notifier).toggleTheme();
        break;
      case 'logout':
        ref.read(authStateProvider.notifier).logout();
        context.go('/login');
        break;
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'theme',
      child: Row(
        children: [
          Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          const SizedBox(width: 12),
          const Text('Sáng tối'),
          const Spacer(),
          Switch(
            value: isDark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem(
      value: 'logout',
      child: Row(
        children: [
          Icon(Icons.logout),
          SizedBox(width: 12),
          Text('Đăng xuất'),
        ],
      ),
    ),
  ],
),
```

**Files Modified**:
- `lib/src/ui/features/sinhvien/list/sinhvien_list_page.dart`
- `lib/src/ui/features/nganh/list/nganh_list_page.dart`
- `lib/src/ui/features/report/report_page.dart`

---

### 2. **BottomNavigationBar - Reduced from 4 to 3 Items**

#### Before:
```
├─ 0️⃣  Sinh viên
├─ 1️⃣  Ngành
├─ 2️⃣  Báo cáo
└─ 3️⃣  Đăng xuất  ❌ REMOVED
```

#### After:
```
├─ 0️⃣  Sinh viên
├─ 1️⃣  Ngành
└─ 2️⃣  Báo cáo
```

The logout switch case was removed from the `onTap` handler:
```dart
// Removed:
case 3:
  ref.read(authStateProvider.notifier).logout();
  context.go('/login');
  break;
```

---

### 3. **Remove Back Button from Non-Main Pages**

Added `automaticallyImplyLeading: false` to prevent the back button from appearing on:

#### Files Modified:
1. **`sinhvien_detail_page.dart`** (Student Detail page)
   ```dart
   appBar: AppBar(
     title: const Text('Chi tiết Sinh viên'),
     automaticallyImplyLeading: false,  // ✅ Added
     actions: [...]
   ),
   ```

2. **`sinhvien_edit_page.dart`** (Create/Edit Student)
   ```dart
   appBar: AppBar(
     title: Text(widget.sinhVienId == null ? 'Thêm Sinh viên' : 'Sửa Sinh viên'),
     automaticallyImplyLeading: false,  // ✅ Added
   ),
   ```

3. **`nganh_edit_page.dart`** (Create/Edit Department)
   ```dart
   appBar: AppBar(
     title: Text(widget.nganhId == null ? 'Thêm Ngành' : 'Sửa Ngành'),
     automaticallyImplyLeading: false,  // ✅ Added
   ),
   ```

---

## Navigation Flow

### Main Pages (Bottom Navigation Available):
- 📚 **Student List** → menu with theme/logout
- 🏫 **Nganh List** → menu with theme/logout
- 📊 **Report** → menu with theme/logout + refresh button

### Detail/Edit Pages (No Back Button):
- Chi tiết Sinh viên → Edit, Delete buttons in AppBar
- Thêm/Sửa Sinh viên → Form with Save/Cancel buttons
- Thêm/Sửa Ngành → Form with Save/Cancel buttons
- Navigation back via BottomNavigationBar or implicit pop when saving

---

## Benefits

✅ **Cleaner Main Pages**: Theme toggle icon removed from AppBar, less clutter
✅ **Better Logout Access**: Logout now in a dedicated menu (not prominent in navigation bar)
✅ **Theme Toggle with Visual Feedback**: Switch control shows theme state directly
✅ **Simplified Navigation**: 3 main sections instead of 4
✅ **Focused Detail Pages**: No confusing back button, use bottom nav or form save/cancel
✅ **Consistent UX**: All main pages have same menu structure
✅ **Reduced Cognitive Load**: Fewer navigation options on non-main pages

---

## Testing Checklist

- [x] Menu button appears on all main pages (Student, Nganh, Report)
- [x] Theme toggle switch works correctly (shows current state)
- [x] Logout from menu works from all pages
- [x] BottomNavigationBar has 3 items (no logout)
- [x] Detail page (Student) has no back button
- [x] Edit page (Student) has no back button
- [x] Edit page (Nganh) has no back button
- [x] Navigation between pages works via BottomNavigationBar
- [x] App compiles without errors
- [x] App runs on emulator successfully

---

## Files Modified Summary

| File | Changes |
|------|---------|
| `sinhvien_list_page.dart` | Added menu with theme/logout, removed logout from nav |
| `nganh_list_page.dart` | Added menu with theme/logout, removed logout from nav |
| `report_page.dart` | Added menu with theme/logout, removed logout from nav |
| `sinhvien_detail_page.dart` | Added `automaticallyImplyLeading: false` |
| `sinhvien_edit_page.dart` | Added `automaticallyImplyLeading: false` |
| `nganh_edit_page.dart` | Added `automaticallyImplyLeading: false` |

**Total**: 6 files modified

---

## Code Pattern Used

### Menu Implementation:
```dart
PopupMenuButton<String>(
  onSelected: (value) {
    switch (value) {
      case 'theme':
        ref.read(themeModeProvider.notifier).toggleTheme();
        break;
      case 'logout':
        ref.read(authStateProvider.notifier).logout();
        context.go('/login');
        break;
    }
  },
  itemBuilder: (context) => [
    // Theme toggle with switch
    PopupMenuItem(
      value: 'theme',
      child: Row(
        children: [
          Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          const SizedBox(width: 12),
          const Text('Sáng tối'),
          const Spacer(),
          Switch(
            value: isDark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
    const PopupMenuDivider(),
    // Logout option
    const PopupMenuItem(
      value: 'logout',
      child: Row(
        children: [
          Icon(Icons.logout),
          SizedBox(width: 12),
          Text('Đăng xuất'),
        ],
      ),
    ),
  ],
),
```

### Back Button Removal:
```dart
appBar: AppBar(
  title: const Text('Page Title'),
  automaticallyImplyLeading: false,  // Disables back button
),
```

---

## Version
- **Date**: October 21, 2025
- **Status**: ✅ Completed and tested
- **Build**: Successful on Android emulator
- **Type**: UI/UX Navigation Refactor
