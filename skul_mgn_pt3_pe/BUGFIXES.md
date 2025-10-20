# Bug Fixes - October 20, 2025

## Issues Fixed

### 1. ❌ FormatException when adding new Nganh
**Problem**: When clicking "Thêm Ngành" button, app crashed with error:
```
FormatException: Invalid radix-10 number (at character 1)
new
```

**Root Cause**: The FAB button was navigating to `/nganh/new/edit`, and the router tried to parse "new" as an integer ID in the path parameter.

**Solution**: Changed navigation route from `/nganh/new/edit` to `/nganh/create` in `nganh_list_page.dart`.

**Files Modified**:
- `lib/src/ui/features/nganh/list/nganh_list_page.dart` (line 218)

```dart
// Before
onPressed: () => context.push('/nganh/new/edit'),

// After
onPressed: () => context.push('/nganh/create'),
```

---

### 2. 🔄 Lists not reloading after create/update

**Problem**: After creating or editing a student/department and returning to the list, changes were not visible until manual refresh or app restart.

**Root Cause**: The list/detail pages were using `context.push()` without awaiting the result, so they didn't know when to refresh the data after the user returned from edit pages.

**Solution**: 

1. Made all navigation calls `async` and added `await`
2. Called refresh method after returning from create/edit pages:
   - **Student List**: `ref.read(_studentListProvider.notifier).loadStudents()`
   - **Student Detail**: `ref.invalidate(_studentDetailProvider(sinhVienId))`
   - **Nganh List**: `ref.invalidate(_nganhListProvider)`
3. Applied to:
   - Student list → detail view
   - Student list → create new
   - Student detail → edit
   - Nganh list → edit
   - Nganh list → create new

**Files Modified**:

- `lib/src/ui/features/sinhvien/list/sinhvien_list_page.dart` (lines 334, 375)
- `lib/src/ui/features/sinhvien/detail/sinhvien_detail_page.dart` (line 102)
- `lib/src/ui/features/nganh/list/nganh_list_page.dart` (lines 209, 218)

**Example - Nganh List**:

```dart
// Before - Edit button
onTap: () => context.push('/nganh/${nganh.id}/edit'),

// After - Edit button
onTap: () async {
  await context.push('/nganh/${nganh.id}/edit');
  // Reload list after returning from edit
  ref.invalidate(_nganhListProvider);
},

// Before - Create button (FAB)
onPressed: () => context.push('/nganh/create'),

// After - Create button (FAB)
onPressed: () async {
  await context.push('/nganh/create');
  // Reload list after returning from create
  ref.invalidate(_nganhListProvider);
},
```

**Example - Student Detail**:

```dart
// Before - Edit button in AppBar
onPressed: () {
  context.push('/sv/$sinhVienId/edit');
},

// After - Edit button in AppBar
onPressed: () async {
  await context.push('/sv/$sinhVienId/edit');
  // Reload detail page after returning from edit
  ref.invalidate(_studentDetailProvider(sinhVienId));
},
```

---

### 3. 📍 SnackBar messages at bottom instead of top
**Problem**: All success/error messages appeared at the bottom of the screen, making them easy to miss (especially on large screens or when keyboard is visible).

**Root Cause**: Default Flutter SnackBar behavior shows messages at the bottom.

**Solution**: 
1. Created reusable helper functions in `snackbar_utils.dart`:
   - `showTopSnackBar()` - Generic top snackbar with custom styling
   - `showSuccessSnackBar()` - Green background with check icon
   - `showErrorSnackBar()` - Red background with error icon
   - `showInfoSnackBar()` - Blue background with info icon

2. Replaced all `ScaffoldMessenger.of(context).showSnackBar()` calls with new helper functions throughout the app

**Files Created**:
- `lib/src/common/snackbar_utils.dart`

**Files Modified**:
- `lib/src/ui/features/sinhvien/edit/sinhvien_edit_page.dart`
- `lib/src/ui/features/sinhvien/list/sinhvien_list_page.dart`
- `lib/src/ui/features/nganh/list/nganh_list_page.dart`
- `lib/src/ui/features/nganh/edit/nganh_edit_page.dart`

**Implementation**:
```dart
// Helper function with floating behavior
void showTopSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 100,
        left: 10,
        right: 10,
      ),
    ),
  );
}
```

**Before** (example from student edit):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Đã thêm sinh viên'),
  ),
);
```

**After**:
```dart
showSuccessSnackBar(context, 'Đã thêm sinh viên');
```

---

## Benefits

1. **Better Error Handling**: Users can now create departments without crashes
2. **Improved UX**: Data always stays fresh - no stale information after any create/update operation
3. **Enhanced Visibility**: Messages appear at eye level with color-coded icons:
   - ✅ Green for success
   - ❌ Red for errors
   - ℹ️ Blue for info
4. **Code Quality**: Centralized message handling makes code cleaner and more maintainable
5. **Consistent Behavior**: All CRUD operations now properly refresh their parent lists/details

---

## Testing Checklist

- [x] Create new Nganh - should work without error AND list should refresh
- [x] Edit Nganh - list should show updated data immediately
- [x] Create new Student - list should refresh automatically
- [x] Edit student from list - list should show updated data immediately
- [x] Edit student from detail - detail page should refresh automatically
- [x] Delete student - list should refresh automatically
- [x] All success messages appear at top with green background
- [x] All error messages appear at top with red background
- [x] Import contacts - success message appears at top
- [x] Geocode address - success/error messages at top

---

## Files Summary

**New Files**:
- `lib/src/common/snackbar_utils.dart` (59 lines)

**Modified Files**:
- `lib/src/ui/features/nganh/list/nganh_list_page.dart` - Added reload after create/edit
- `lib/src/ui/features/nganh/edit/nganh_edit_page.dart` - Updated snackbar messages
- `lib/src/ui/features/sinhvien/list/sinhvien_list_page.dart` - Added reload after detail/create
- `lib/src/ui/features/sinhvien/detail/sinhvien_detail_page.dart` - Added reload after edit
- `lib/src/ui/features/sinhvien/edit/sinhvien_edit_page.dart` - Updated snackbar messages

**Total Changes**: ~200 lines modified across 6 files

---

## Version
- **Date**: October 20, 2025
- **Status**: ✅ All issues resolved and tested
- **Build**: Successful on Android emulator
- **Update**: Fixed reload issues for both Student and Nganh create/update operations
