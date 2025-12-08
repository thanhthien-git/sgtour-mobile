# ⚡ Auto Reload Giống NextJS - Hướng Dẫn Cấu Hình

## 🎯 Mục Tiêu

Bạn muốn: **Ctrl+S (save) → Tự động reload app** (giống NextJS)

## ✅ Cấu Hình Đã Hoàn Tất

Tôi đã tạo 2 file cấu hình cho VS Code:

### 1. `.vscode/settings.json` ✅

- Auto-save files mỗi 500ms
- Auto hot reload khi save
- Auto format code
- Auto organize imports

### 2. `.vscode/launch.json` ✅

- Cấu hình Flutter debug mode
- Bật hot reload mode

---

## 🚀 Cách Dùng (3 Bước)

### Step 1: Mở VS Code

```bash
code /home/thien/Desktop/sgtour-mobile
```

### Step 2: Bắt Đầu Debug

Ấn **`F5`** hoặc:

- Click biểu tượng **Run** (▶️) bên trái
- Chọn **Flutter**
- Ấn **Start Debugging**

hoặc terminal:

```bash
flutter run --hot -d emulator-5554
```

### Step 3: Bắt Đầu Code!

```
Ctrl+S (save) → Auto reload trong 1 giây ⚡
```

---

## 📋 Cách Hoạt Động

```
Bạn sửa code
    ↓
Ấn Ctrl+S (save)
    ↓
VS Code tự động save (500ms)
    ↓
Flutter tự động hot reload (500ms)
    ↓
App cập nhật trên emulator ⚡
    ↓
Tổng cộng: ~1 giây (giống NextJS!)
```

---

## ⚙️ Cấu Hình Chi Tiết

### Settings.json đã bật:

```json
{
  "dart.hotReloadOnSave": true, // Auto hot reload
  "files.autoSave": "afterDelay", // Auto save
  "files.autoSaveDelay": 500, // Save sau 500ms
  "editor.formatOnSave": true, // Format code khi save
  "editor.codeActionsOnSave": {
    "source.fixAll.dart": "explicit", // Fix Dart issues
    "source.organizeImports.dart": "explicit" // Organize imports
  }
}
```

---

## 📚 Phím Tắt Quan Trọng

| Phím             | Tác Dụng           |
| ---------------- | ------------------ |
| **F5**           | Start/Debug app    |
| **Ctrl+S**       | Save (auto reload) |
| **Ctrl+Shift+D** | Open debug panel   |
| **F6**           | Hot reload nếu cần |

---

## ✅ Bây Giờ Bạn Có:

| Feature          | Status      |
| ---------------- | ----------- |
| Auto Save        | ✅ 500ms    |
| Hot Reload       | ✅ Khi save |
| Format Code      | ✅ Khi save |
| Auto Imports     | ✅ Khi save |
| **Giống NextJS** | ✅ **CÓ!**  |

---

## 🧪 Test Ngay

### Test 1: Thay Đổi Text

**File:** `lib/main.dart`

```dart
// Tìm dòng:
Text('Welcome to ${AppConfig.appName}',

// Đổi thành:
Text('Hello SGTour! 🎉',
```

**Làm:** Ctrl+S → **Xem text thay đổi trong 1 giây!** ⚡

### Test 2: Thay Đổi Màu

**File:** `lib/config/app_colors.dart`

```dart
// Đổi:
static const Color primary = Color(0xFF1976D2);

// Thành:
static const Color primary = Color(0xFFFF6B6B);  // Red
```

**Làm:** Ctrl+S → **Xem màu thay đổi ngay!** ⚡

---

## 🎯 Workflow Thực Tế

```bash
# Step 1: Mở project
code /home/thien/Desktop/sgtour-mobile

# Step 2: Ấn F5 để start
# (hoặc flutter run --hot)

# Step 3: Edit code
# Sửa bất kỳ file nào

# Step 4: Ctrl+S để save
# Auto reload tự động! ⚡

# Lặp lại từ Step 3
```

---

## 💡 Pro Tips

**Tip 1:** Bạn không cần ấn `r` nữa

- Trước: Sửa code → Bấn `r`
- Bây giờ: Sửa code → Ctrl+S (tự động reload)

**Tip 2:** Nếu auto reload không hoạt động

- Ấn F5 để debug lại
- Hoặc dùng `flutter run --hot`

**Tip 3:** Nếu muốn tắt auto reload

- Mở `.vscode/settings.json`
- Sửa: `"dart.hotReloadOnSave": false`

**Tip 4:** Hot reload vẫn có giới hạn

- Thêm package → cần hot restart
- Sửa pubspec.yaml → cần hot restart
- UI changes → auto reload ✅

---

## 🔧 Nếu Vẫn Không Hoạt Động

### Option 1: Dùng Terminal (Backup)

```bash
cd /home/thien/Desktop/sgtour-mobile
flutter run --hot -d emulator-5554
```

Rồi bấn `r` theo cách cũ

### Option 2: Cài đặt lại Extension

1. Mở VS Code
2. Extension → Tìm "Flutter"
3. Cài đặt extension Flutter official

### Option 3: Restart VS Code

```bash
code /home/thien/Desktop/sgtour-mobile
```

Rồi ấn F5

---

## 📊 So Sánh

| Framework         | Save → Reload | Thời Gian    |
| ----------------- | ------------- | ------------ |
| **NextJS**        | Ctrl+S → auto | 1-2 sec      |
| **Flutter (Cũ)**  | r + Enter     | 1-3 sec      |
| **Flutter (Mới)** | Ctrl+S → auto | **1 sec ⚡** |

**Bây giờ bạn có NextJS-style development! 🎉**

---

## 🎓 Tóm Tắt

✅ Cấu hình VS Code: HOÀN TẤT
✅ Auto save: HOÀN TẤT
✅ Hot reload on save: HOÀN TẤT
✅ Format on save: HOÀN TẤT

**Bạn sẵn sàng để code!** 🚀

---

## 📞 Nếu Cần Giúp

1. Mở VS Code
2. Ấn F5
3. Sửa code
4. Ấn Ctrl+S
5. **Xem thay đổi ngay! ⚡**

Chúc bạn phát triển vui vẻ! 💻
