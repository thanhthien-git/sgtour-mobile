# Nội dung khai báo cho Apple App Store Connect (SGTour Mobile)

Tài liệu này tổng hợp các nội dung cần điền khi publish app **SGTour Mobile** lên App Store qua [App Store Connect](https://appstoreconnect.apple.com).

---

## 1. Thông tin App (App Information)

| Trường | Giá trị gợi ý |
|--------|----------------|
| **Tên app (Primary Language)** | SGTour Mobile |
| **Phụ đề (Subtitle)** — tối đa 30 ký tự | Du lịch thông minh, bản đồ & điểm đến |
| **Category (Thể loại chính)** | Travel (Du lịch) |
| **Category phụ (optional)** | Navigation (Điều hướng) hoặc Lifestyle |
| **Bundle ID** | `com.sgtour.sgtourcus` *(kiểm tra lại trong Xcode/Apple Developer)* |

---

## 2. Mô tả & từ khóa (Version Information)

### 2.1 Mô tả app (Description) — tối đa 4000 ký tự

**Tiếng Việt (dùng cho bản tiếng Việt trên Store):**

```
SGTour Mobile là ứng dụng du lịch thông minh, giúp bạn khám phá điểm đến, xem bản đồ và quản lý hành trình dễ dàng.

TÍNH NĂNG CHÍNH:
• Bản đồ tương tác — Xem vị trí, địa điểm du lịch và định vị xung quanh bạn
• Quét mã QR — Quét mã QR tại điểm đến để lấy thông tin nhanh
• Tìm kiếm địa điểm — Tìm và xem chi tiết địa danh, dịch vụ du lịch
• Đa ngôn ngữ — Hỗ trợ tiếng Việt và tiếng Anh
• Trợ lý giọng nói — Tìm kiếm bằng giọng nói, trải nghiệm thuận tiện
• Đăng nhập Google — Đăng nhập nhanh, đồng bộ an toàn
• Bảo mật — Xác thực vân tay / Face ID tùy chọn

SGTour Mobile được thiết kế cho du khách và người dùng quan tâm đến du lịch, văn hóa và khám phá địa phương. Tải app để bắt đầu hành trình của bạn.
```

**Tiếng Anh (dùng cho bản tiếng Anh / mặc định):**

```
SGTour Mobile is a smart travel app that helps you discover destinations, view maps, and manage your trips with ease.

KEY FEATURES:
• Interactive map — View locations, tourist spots, and places around you
• QR code scanner — Scan QR codes at venues for quick information
• Place search — Find and explore destinations and travel services
• Multi-language — Vietnamese and English supported
• Voice assistant — Search by voice for a convenient experience
• Google Sign-in — Quick login and secure sync
• Security — Optional fingerprint / Face ID authentication

SGTour Mobile is designed for travelers and anyone interested in tourism, culture, and local discovery. Download to start your journey.
```

### 2.2 Từ khóa (Keywords) — tối đa 100 ký tự, ngăn cách bằng dấu phẩy

```
du lịch,travel,bản đồ,map,điểm đến,destination,QR,tour,sgtour,khám phá
```

*(Tiếng Anh: `travel,map,destination,QR,tour,sgtour,explore,tourism,navigation`)*

### 2.3 Ghi chú phiên bản (What’s New) — tối đa 4000 ký tự

**Lần release đầu (ví dụ):**

```
Phiên bản đầu tiên của SGTour Mobile.

• Bản đồ tương tác với địa điểm du lịch
• Quét mã QR tại điểm đến
• Tìm kiếm địa điểm và xem chi tiết
• Hỗ trợ tiếng Việt và tiếng Anh
• Đăng nhập Google và bảo mật bằng vân tay/Face ID

Cảm ơn bạn đã sử dụng SGTour. Mọi góp ý xin gửi về support@sgtour.com.
```

---

## 3. URL bắt buộc

| Trường | URL gợi ý | Ghi chú |
|--------|------------|--------|
| **Privacy Policy URL** | `https://www.sgtour.com/privacy` | Bắt buộc; cần có trang Chính sách bảo mật thật |
| **Support URL** | `https://www.sgtour.com/support` hoặc `mailto:support@sgtour.com` | Thường dùng trang web hoặc form liên hệ |
| **Marketing URL** (optional) | `https://www.sgtour.com` | Trang giới thiệu app / công ty |

**Lưu ý:** Thay `sgtour.com` bằng domain thật của bạn nếu khác. Đảm bảo trang Privacy Policy đã xuất bản và truy cập được trước khi submit.

---

## 4. Khai báo quyền sử dụng (Usage Description) — đã cấu hình trong Info.plist

Các mô tả sau **đã có** trong `ios/Runner/Info.plist`. Chỉ cần đảm bảo nội dung phù hợp với cách app sử dụng khi Apple review:

| Quyền | Mục đích khai báo |
|-------|--------------------|
| **NSCameraUsageDescription** | Quét mã QR |
| **NSMicrophoneUsageDescription** | Ghi âm và nhận diện giọng nói |
| **NSSpeechRecognitionUsageDescription** | Tìm kiếm bằng giọng nói |
| **NSLocationWhenInUseUsageDescription** | Hiển thị bản đồ và địa điểm xung quanh |
| **NSLocationAlwaysAndWhenInUseUsageDescription** | Bản đồ và địa điểm (nếu dùng nền) |
| **NSPhotoLibraryUsageDescription** | Truy cập thư viện ảnh |
| **NSPhotoLibraryAddUsageDescription** | Lưu ảnh vào thư viện |
| **NSBluetoothAlwaysUsageDescription** | Kết nối thiết bị âm thanh (nếu dùng) |
| **NSLocalNetworkUsageDescription** | Khám phá thiết bị trên mạng nội bộ (nếu dùng) |

Nếu không dùng Bluetooth hoặc Local Network cho tính năng chính, có thể cân nhắc bỏ hoặc làm rõ lý do trong “Notes for Reviewer”.

---

## 5. Tuổi (Age Rating) — Câu hỏi khai báo

Khi làm bảng câu hỏi Age Rating trong App Store Connect, tham khảo:

| Câu hỏi | Gợi ý trả lời (thường 4+) |
|---------|---------------------------|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Sexual Content or Nudity | None |
| Profanity or Crude Humor | None |
| Horror/Fear Themes | None |
| Mature/Suggestive Themes | None |
| Gambling | None |
| Unrestricted Web Access | Có thể **Yes** nếu app mở WebView (xem chính sách, điều khoản). Nếu chỉ mở URL cố định nội bộ thì có thể **No**. |
| Gambling and Contests | None |
| Alcohol, Tobacco, or Drug Use | None |

Kết quả thường là **4+**. Nếu có nội dung người dùng tạo (UGC) hoặc mạng xã hội, trả lời theo đúng tính năng thực tế.

---

## 6. Xuất khẩu & mã hóa (Export Compliance)

Trong **Info.plist** đã có:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Trong App Store Connect:

- **Does your app use encryption?**  
  Chọn **No** nếu app chỉ dùng HTTPS/SSL chuẩn (TLS) và không có mã hóa tùy chỉnh hoặc mã hóa đặc biệt phải khai báo.  
  Nếu chọn **Yes**, bạn sẽ cần điền thêm form xuất khẩu (ví dụ BIS).

---

## 7. Quyền nội dung (Content Rights)

Khi submit, Apple sẽ hỏi bạn xác nhận:

- Bạn có quyền sử dụng toàn bộ nội dung trong app (hình ảnh, văn bản, nhãn hiệu, v.v.).
- Nội dung không vi phạm bản quyền hoặc quyền riêng tư của bên thứ ba.

**Câu trả lời gợi ý:** Chọn xác nhận rằng bạn sở hữu hoặc có quyền sử dụng tất cả nội dung; nếu dùng ảnh/API bên thứ ba (ví dụ bản đồ, ảnh địa điểm), đảm bảo tuân thủ điều khoản sử dụng của nhà cung cấp.

---

## 8. Quảng cáo (Advertising Identifier — IDFA)

- App **không** sử dụng IDFA (không có AdMob, quảng cáo theo dõi, v.v.) → trong bước **App Privacy** / **Advertising** chọn **No** hoặc tương đương “Does not use advertising identifier”.
- Nếu sau này tích hợp quảng cáo hoặc SDK dùng IDFA, cần bật **App Tracking Transparency** (ATT) và khai báo lại.

---

## 9. App Privacy (Quyền riêng tư)

Trong **App Store Connect → App Privacy**, khai báo theo đúng cách app thu thập/sử dụng dữ liệu.

Gợi ý khai báo cho SGTour Mobile (chỉ mang tính tham khảo; cần rà soát với code và backend thực tế):

| Loại dữ liệu | Thu thập? | Mục đích | Liên kết với danh tính? |
|--------------|-----------|----------|--------------------------|
| **Vị trí** (Location) | Có | Hiển thị bản đồ, địa điểm gần bạn | Có thể (nếu gắn với tài khoản) |
| **Thông tin liên hệ** (Email, tên từ Google) | Có (nếu dùng Google Sign-in) | Tạo tài khoản, hỗ trợ | Có |
| **User ID / Identifier** | Có (ID đăng nhập) | Xác thực, đồng bộ | Có |
| **Ảnh / Thư viện** | Có thể (nếu app truy cập ảnh) | Lưu/đăng ảnh (nếu có) | Tùy tính năng |
| **Âm thanh / Giọng nói** | Có (nhận diện giọng nói) | Tìm kiếm bằng giọng nói | Có thể (nếu gắn tài khoản) |
| **Dữ liệu sử dụng** (analytics) | Có thể | Cải thiện app (nếu bật analytics) | Tùy cấu hình |

- **Data Linked to User:** Chọn đúng theo việc dữ liệu có gắn với tài khoản hay không.
- **Data Used for Tracking:** Chọn **No** nếu không dùng dữ liệu cho quảng cáo/theo dõi bên thứ ba.

Đảm bảo **Privacy Policy URL** phản ánh đúng các mục đã khai báo.

---

## 10. Thông tin cho bên Review (App Review Information)

Điền trong **App Store Connect → App Review Information**:

| Trường | Gợi ý |
|--------|--------|
| **Contact - First Name** | Tên người liên hệ |
| **Contact - Last Name** | Họ |
| **Contact - Phone** | Số điện thoại |
| **Contact - Email** | Email nhận thông báo review (ví dụ dev@sgtour.com) |
| **Demo account (Username)** | Tài khoản test nếu app yêu cầu đăng nhập |
| **Demo account (Password)** | Mật khẩu test |
| **Notes** | Ví dụ: "App uses location only when the user opens the map. QR scanner requires camera. Sign in can be tested with the provided demo account. Privacy policy: [URL]." |

Nếu không cần đăng nhập để dùng đầy đủ, có thể ghi trong Notes: "No login required to use map and QR scanner."

---

## 11. Giá & phân phối (Pricing and Availability)

| Mục | Gợi ý |
|-----|--------|
| **Price** | Free (Miễn phí) hoặc chọn giá nếu bán app |
| **Availability** | Chọn các quốc gia/vùng muốn phân phối (ví dụ Vietnam, United States, …) |

---

## 12. Checklist trước khi Submit

- [ ] Bundle ID trùng với App ID trên Apple Developer.
- [ ] Version và Build number đã tăng (ví dụ 1.0.0 build 1).
- [ ] Privacy Policy URL mở được và nội dung đúng với app.
- [ ] Support URL hoặc email hoạt động.
- [ ] Đã khai báo Age Rating, Export Compliance, Content Rights.
- [ ] App Privacy khai báo đúng với tính năng (vị trí, đăng nhập, v.v.).
- [ ] Đã cung cấp tài khoản demo (nếu app cần đăng nhập).
- [ ] Screenshots và preview (video) đúng kích thước theo yêu cầu Apple.
- [ ] Info.plist có đủ Usage Description cho Camera, Location, Microphone, Speech Recognition, Photo Library (đã có trong project).

---

## 13. Tài liệu tham khảo

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Export Compliance (encryption)](https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations)
- [Privacy – App Store](https://developer.apple.com/app-store/user-privacy-and-data-use/)

---

*Tài liệu soạn cho dự án SGTour Mobile. Cập nhật lại URL, tên công ty và nội dung khai báo theo thực tế trước khi submit.*
