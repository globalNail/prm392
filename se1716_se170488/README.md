# Ứng dụng sản phẩm (Flutter)

Ứng dụng mẫu gồm 2 trang: Đăng nhập và Danh sách sản phẩm. Người dùng có thể xem danh sách sản phẩm bằng ListView, tìm kiếm, thêm/xoá/sửa, và xem chi tiết sản phẩm.

## Tính năng

- Thiết kế có các layout (AppBar, ListView, BottomSheet, Dialog, Card)
- 2 pages: Đăng nhập, Danh sách sản phẩm
- Hiển thị sản phẩm bằng ListView: mỗi item có ảnh và tên sản phẩm
- Chọn sản phẩm để xem chi tiết (ảnh lớn, tên, mô tả)
- Thêm, xoá, sửa sản phẩm (BottomSheet form)
- Tìm kiếm sản phẩm theo tên (ô tìm kiếm trên AppBar)

## Cách chạy

1. Cài Flutter SDK và thiết bị giả lập/thiết bị thật
2. Lấy dependencies và chạy ứng dụng

```powershell
flutter pub get; flutter run
```

## Ghi chú

- Dữ liệu sản phẩm được lưu tạm trong bộ nhớ (không có backend). Khởi động lại app sẽ về dữ liệu mẫu.
- Ảnh mặc định dùng placeholder nếu URL trống hoặc lỗi.
