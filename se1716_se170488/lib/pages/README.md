# BasePage Documentation

## Tổng quan

`BasePage` là một abstract class cung cấp các chức năng cơ bản cho tất cả các page trong ứng dụng Flutter. Nó được thiết kế để giảm thiểu code lặp lại và cung cấp các tính năng chung như loading, error handling, navigation, và nhiều hơn nữa.

## Cách sử dụng

### 1. Tạo một page mới

```dart
import 'package:flutter/material.dart';
import 'base_page.dart';

class MyPage extends BasePage {
  const MyPage({super.key}) : super(
    title: 'My Page Title',
    // Các tùy chọn khác...
  );

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends BasePageState<MyPage> {
  @override
  Widget buildBody() {
    return Column(
      children: [
        Text('Hello World'),
        ElevatedButton(
          onPressed: () => showSuccess('Success message!'),
          child: Text('Show Success'),
        ),
      ],
    );
  }
}
```

### 2. Tùy chỉnh AppBar

```dart
class MyPage extends BasePage {
  const MyPage({super.key}) : super(
    title: 'My Page',
    showBackButton: true, // Hiển thị nút back (mặc định: true)
    centerTitle: true,    // Căn giữa title (mặc định: true)
    actions: [            // Thêm actions vào AppBar
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () => print('Settings'),
      ),
    ],
  );
}
```

### 3. Sử dụng các chức năng có sẵn

#### Loading Management

```dart
void _performAsyncOperation() async {
  showLoading(); // Hiển thị loading overlay
  
  try {
    await someAsyncOperation();
    hideLoading(); // Ẩn loading
    showSuccess('Operation completed!');
  } catch (e) {
    hideLoading();
    showError('Error: $e');
  }
}
```

#### Error Handling

```dart
void _handleError() {
  showError('This is an error message');
  // Error sẽ được hiển thị dưới dạng SnackBar màu đỏ
}

void _handleSuccess() {
  showSuccess('Operation successful!');
  // Success sẽ được hiển thị dưới dạng SnackBar màu xanh
}
```

#### Confirmation Dialog

```dart
void _confirmAction() async {
  final confirmed = await showConfirmationDialog(
    title: 'Xác nhận',
    content: 'Bạn có chắc chắn muốn thực hiện hành động này?',
    confirmText: 'Có',
    cancelText: 'Không',
  );
  
  if (confirmed) {
    // Thực hiện hành động
  }
}
```

#### Navigation

```dart
void _navigateToNewPage() {
  navigateTo(AnotherPage()); // Navigate đến page mới
}

void _replaceCurrentPage() {
  navigateToReplacement(HomePage()); // Replace page hiện tại
}

void _goBack() {
  goBack(); // Quay lại page trước
  // hoặc goBack(result); // Quay lại với kết quả
}
```

### 4. Lifecycle Methods

```dart
class _MyPageState extends BasePageState<MyPage> {
  @override
  void onInitState() {
    // Code khởi tạo ở đây
    // Được gọi trong initState()
  }

  @override
  void onDispose() {
    // Code cleanup ở đây
    // Được gọi trong dispose()
  }
}
```

### 5. Database Service

```dart
class _MyPageState extends BasePageState<MyPage> {
  void _useDatabase() {
    // DatabaseService đã được inject sẵn
    final data = dbService.getData();
  }
}
```

## Các tính năng có sẵn

### Properties của BasePage

- `title`: Tiêu đề của page
- `showBackButton`: Hiển thị nút back (mặc định: true)
- `actions`: Danh sách actions cho AppBar
- `floatingActionButton`: FAB widget
- `floatingActionButtonLocation`: Vị trí của FAB
- `backgroundColor`: Màu nền
- `resizeToAvoidBottomInset`: Tự động resize khi keyboard xuất hiện
- `drawer`: Navigation drawer
- `endDrawer`: End drawer
- `centerTitle`: Căn giữa title (mặc định: true)

### Methods của BasePageState

- `showLoading()`: Hiển thị loading overlay
- `hideLoading()`: Ẩn loading overlay
- `showError(String message)`: Hiển thị error message
- `showSuccess(String message)`: Hiển thị success message
- `clearError()`: Xóa error message
- `showConfirmationDialog()`: Hiển thị dialog xác nhận
- `navigateTo<R>(Widget page)`: Navigate đến page mới
- `navigateToReplacement<R>(Widget page)`: Replace page hiện tại
- `goBack([result])`: Quay lại page trước
- `onInitState()`: Override để khởi tạo
- `onDispose()`: Override để cleanup

### Properties có thể truy cập

- `isLoading`: Trạng thái loading hiện tại
- `errorMessage`: Error message hiện tại
- `dbService`: DatabaseService instance

## Ví dụ hoàn chỉnh

Xem file `example_page.dart` và `login_page.dart` để có ví dụ hoàn chỉnh về cách sử dụng `BasePage`.

## Lưu ý

1. Luôn extend `BasePage` thay vì `StatefulWidget`
2. State class phải extend `BasePageState<YourPage>`
3. Implement method `buildBody()` thay vì `build()`
4. Sử dụng `onInitState()` và `onDispose()` thay vì `initState()` và `dispose()`
5. Tận dụng các utility methods có sẵn để giảm code lặp lại
