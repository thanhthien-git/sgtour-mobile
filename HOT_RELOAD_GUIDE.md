# 🔥 Hot Reload Guide for SGTour Flutter App

## ✅ Hot Reload **CÓ HOẠT ĐỘNG** trên Project Này

Yes! Hot reload **works perfectly** on your SGTour project. Here's how to use it:

---

## 🚀 How to Use Hot Reload

### Method 1: Command Line (Easiest)

```bash
cd /home/thien/Desktop/sgtour-mobile
flutter run
```

Then while the app is running:
- Press **`r`** to hot reload
- Press **`R`** to hot restart
- Press **`q`** to quit

### Method 2: VS Code (Recommended)

1. Open VS Code
2. Open your Flutter project: `File → Open Folder → select sgtour-mobile`
3. Open terminal in VS Code: `Ctrl + ~`
4. Run: `flutter run`
5. Press **`r`** for hot reload during development

### Method 3: Android Studio / IntelliJ

1. Open your Flutter project
2. Click **Run → Run 'main.dart'**
3. Once running, click the 🔥 **"Hot Reload"** button in the toolbar
4. Or press **`Ctrl + \`** (Windows) / **`⌘ + \`** (Mac)

---

## 💡 What Hot Reload Does

**Hot Reload** giúp bạn:
- ✅ Thay đổi UI code → **thấy ngay lập tức** (1-2 giây)
- ✅ **Giữ nguyên app state** (không cần reset app)
- ✅ Làm việc nhanh hơn khi phát triển
- ✅ **Không cần rebuild** toàn bộ ứng dụng

### What Hot Reload Does NOT Do

- ❌ Không cập nhật code trong `main()` function
- ❌ Không cập nhật global variables
- ❌ Không thay đổi kích thước asset
- ❌ Không cập nhật pubspec.yaml
- ❌ Không thêm package mới

---

## 🔄 When to Use Hot Reload vs Hot Restart

### Use **Hot Reload** (`r`) When:
✅ Thay đổi UI (màu, font, layout)
✅ Thay đổi widget properties
✅ Thay đổi logic trong build()
✅ Thay đổi colors/text styles

**Example:**
```dart
// ✅ Hot reload works
Text('Welcome', style: AppTextStyles.heading2)  // Change this
```

### Use **Hot Restart** (`R`) When:
- ✅ Thay đổi state management
- ✅ Thay đổi main()
- ✅ Thêm package mới
- ✅ Thay đổi provider
- ✅ Reset app state

**Example:**
```dart
// ❌ Cần hot restart
class MyProvider extends ChangeNotifier {
  int count = 0;  // Thay đổi này
}
```

---

## 📝 Test Hot Reload Now

### Step 1: Run the App
```bash
flutter run
```

Wait for app to load on emulator (2-3 minutes first time)

### Step 2: Make a Simple Change
Edit `lib/main.dart`:

```dart
// Find this line:
Text('Welcome to ${AppConfig.appName}',

// Change to:
Text('Hello SGTour!',  // ← Change this text
```

### Step 3: Save and Hot Reload
- Save file (Ctrl+S)
- Press **`r`** in terminal
- **See the change appear in 1-2 seconds!** ✨

---

## 🔧 Troubleshooting Hot Reload

### Problem: Hot Reload Not Working
**Solution:** Use Hot Restart
```bash
# In flutter run terminal
R  # Hot Restart (uppercase R)
```

### Problem: Changes Don't Show
**Cause:** Maybe you changed:
- `pubspec.yaml` dependencies
- `main()` function
- Provider initialization
- Asset paths

**Solution:** Hot Restart or rebuild
```bash
# Restart app completely
R
```

### Problem: "Hot Reload Failed"
**Solution:** Use Hot Restart
```bash
# Press R to do Hot Restart
```

### Problem: App Crashes After Hot Reload
**Solution:** Hot Restart
```bash
# Press R (capital R) for full restart
```

---

## 🎯 Quick Reference

| Shortcut | Action | When to Use |
|----------|--------|------------|
| **`r`** | Hot Reload | UI/Widget changes |
| **`R`** | Hot Restart | State/Provider changes |
| **`q`** | Quit | Exit flutter run |
| **`w`** | Dump widget tree | Debug UI |
| **`t`** | Dump rendering tree | Debug layout |
| **`p`** | Toggle performance overlay | Check FPS |

---

## 🎨 Test Hot Reload With These Changes

### Test 1: Change Text (Works with Hot Reload)
```dart
// lib/main.dart
// Change this:
Text('Welcome to ${AppConfig.appName}',

// To this:
Text('🚀 Welcome to SGTour!',
```
✅ Press `r` → Changes appear instantly!

### Test 2: Change Color (Works with Hot Reload)
```dart
// lib/config/app_colors.dart
// Change this:
static const Color primary = Color(0xFF1976D2);

// To this:
static const Color primary = Color(0xFFFF6B6B);  // Red
```
✅ Press `r` → All colors change instantly!

### Test 3: Change Button Style (Works with Hot Reload)
```dart
// lib/main.dart
ElevatedButton(
  onPressed: () {...},
  child: const Text('Toggle Theme'),  // Change text here
)
```
✅ Press `r` → Button text updates!

### Test 4: Add New Widget (Works with Hot Reload)
```dart
// lib/main.dart
// Add a new widget:
const SizedBox(height: 20),
Text('New feature!'),
```
✅ Press `r` → New widget appears!

---

## 🚀 Workflow for Development

### Daily Workflow:
```bash
# 1. Start flutter run once
flutter run

# 2. Edit code
# 3. Save (Ctrl+S)
# 4. Press 'r' for hot reload
# 5. See changes immediately!
```

### If Hot Reload Fails:
```bash
# Press 'R' for hot restart
# or Ctrl+C and run flutter run again
```

---

## 📊 Performance Tips

✅ **Hot Reload is FAST:**
- First build: 2-5 minutes
- Hot reload: 1-3 seconds
- Hot restart: 5-10 seconds

✅ **Keep hot reload speed:**
- Use const constructors
- Avoid large computations in build()
- Keep widget trees simple

---

## 🎓 Best Practices

### ✅ DO Use Hot Reload For:
- Changing colors
- Changing text
- Changing layouts
- Changing widget properties
- Testing UI changes

### ❌ DON'T Use Hot Reload For:
- Adding new packages
- Changing pubspec.yaml
- Changing main()
- Changing provider initialization
- Changing state management

**When in doubt:** Use **Hot Restart** (R) instead

---

## 🔗 Next Steps

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Try hot reload:**
   - Edit `lib/main.dart`
   - Change "Welcome to SGTour" to something else
   - Save (Ctrl+S)
   - Press `r` in terminal

3. **See the magic! ✨**
   The text changes in 1-2 seconds without restarting!

---

## 💡 Pro Tips

**Tip 1:** Use hot reload often
- Makes development 10x faster
- Save → hot reload → test

**Tip 2:** Understand limitations
- Some changes need hot restart
- Know what triggers what

**Tip 3:** Use hot restart when unsure
- Press `R` instead of `r`
- Better safe than sorry

**Tip 4:** Check console output
- Error messages help debug issues
- Read the flutter console

**Tip 5:** Use breakpoints in IDE
- Set breakpoints in VS Code
- Debug with hot reload!

---

## ✅ Your Project Status

| Feature | Status |
|---------|--------|
| Hot Reload Support | ✅ YES |
| Hot Restart Support | ✅ YES |
| Debug Mode | ✅ YES |
| Development Ready | ✅ YES |
| Fast Development | ✅ YES (1-3 sec reload) |

---

## 🎉 Summary

**Có! Hot reload hoạt động tốt trên project này!**

- ✅ Hot reload: `r` (1-3 seconds)
- ✅ Hot restart: `R` (5-10 seconds)
- ✅ Perfect for UI development
- ✅ Fast iteration cycle

**Start developing now:**
```bash
flutter run
```

---

*Updated: December 8, 2025*
*Project: SGTour Mobile App*
*Framework: Flutter*
