# 🔥 قرمشة — Qarmasha

تطبيق Flutter لمطعم دجاج مقرمش وبرجر، مبني على نفس هيكل مشروع **سطر** (واجهة عربية RTL، شاشات منفصلة في `lib/screens`)، ومربوط بـ **Dori API**:
`https://dori.toldpath.com/api/v1` — التوثيق: https://dori.toldpath.com/docs

## ✨ المزايا

- **طريقتان للطلب**
  - 🍽️ **داخل المطعم**: يختار الزبون **رقم الطاولة** (1–30) ويُقدَّم الطلب عليها.
  - 🛵 **توصيل**: يُدخل العنوان (المدينة/الحي، الشارع، العمارة) مع رسوم توصيل.
- صفحة رئيسية بتصميم عصري: بنرات متحركة، تصنيفات دائرية، وجبات مميزة، الأكثر طلباً، عرض حصري.
- منيو كامل مع تصنيفات وترتيب (السعر/الأكثر طلباً) وبحث.
- صفحة تفاصيل الصنف بمعرض صور، ملاحظات للمطبخ، واختيار الكمية.
- سلة، إتمام طلب، شاشة نجاح، **تتبّع حالة الطلب** وإعادة الطلب بضغطة.
- العروض، المفضّلة، الحساب (تسجيل دخول/حساب جديد).
- **لوحة صاحب المطعم**: إضافة أصناف جديدة مع **صور احترافية** (معرض صور جاهز أو رابط صورة) — تُرفع الصور إلى دوري تلقائياً.
- صور الأطعمة احترافية ومجانية من [Pexels](https://www.pexels.com/license/).

## 🔌 الربط مع Dori API

| الوظيفة | Endpoint |
|---|---|
| الصفحة الرئيسية | `GET /places/{slug}/home` |
| المنيو | `GET /places/{slug}/services` |
| التصنيفات | `GET /places/{slug}/categories` |
| تسجيل/دخول العميل | `POST /places/{slug}/auth/register` · `/auth/login` |
| أقرب وقت تجهيز | `GET /places/{slug}/availability/slots` |
| **إرسال الطلب** | `POST /places/{slug}/bookings` |
| حالة الطلبات | `GET /places/{slug}/bookings` |
| دخول المالك | `POST /auth/login` |
| إضافة صنف بالصور | `POST /owner/services` (multipart `images[]`) |
| التصنيفات (المالك) | `GET/POST /owner/categories` |

**كيف يتحول الطلب إلى حجز في دوري؟** كل صنف في المنيو = خدمة (service)، وكل صنف في السلة يُرسل كحجز على أقرب وقت تجهيز متاح، ومعه:
- `notes`: رقم الطلب + «داخل المطعم - طاولة رقم X» أو «توصيل إلى: العنوان» + الكمية.
- `answers`: `order_code`, `order_type` (`dine_in` / `delivery`), `table_number`, `delivery_address`, `quantity`.

## ⚙️ الإعداد

1. أنشئي متجر المطعم على دوري (نوع «أخرى») وانتظري الموافقة.
2. عدّلي `placeSlug` في `lib/core/config.dart` ليطابق رابط المتجر (الافتراضي `qarmasha`).
3. من التطبيق: **حسابي ← لوحة صاحب المطعم** وأضيفي الأصناف بالصور. يُفضّل جعل سعة الصنف كبيرة (التطبيق يرسل `capacity=100` تلقائياً) حتى يقبل المطبخ طلبات متعددة في نفس الوقت.

> قبل تفعيل المتجر، يعرض التطبيق **منيو تجريبي** كامل بالصور ويحاكي الطلب محلياً.

## 🚀 التشغيل

```bash
flutter pub get
flutter run
```

## 📁 الهيكل

```
lib/
├── main.dart
├── core/        # الإعدادات والألوان والثيم
├── data/        # النماذج + ApiService (Dori) + المنيو التجريبي
├── state/       # AppState (السلة، الحساب، الطلبات)
├── widgets/     # البطاقات والأزرار المشتركة
└── screens/
    ├── splash_screen.dart      # البداية + الترحيب
    ├── auth/                   # الدخول وإنشاء الحساب
    ├── main_shell.dart         # شريط التنقل السفلي
    ├── home_screen.dart
    ├── menu_screen.dart
    ├── search_screen.dart
    ├── item_details_screen.dart
    ├── cart_screen.dart
    ├── checkout_screen.dart    # طاولة / توصيل
    ├── order_success_screen.dart
    ├── orders_screen.dart      # طلباتي + التتبّع
    ├── offers_screen.dart
    ├── profile_screen.dart
    └── owner/                  # لوحة صاحب المطعم
```
