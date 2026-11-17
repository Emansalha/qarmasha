/// إعدادات الربط مع منصة دوري (Dori API).
///
/// غيّري [placeSlug] إلى رابط (slug) متجر المطعم بعد إنشائه على
/// https://dori.toldpath.com — مثلاً `qarmasha`.
class AppConfig {
  AppConfig._();

  static const String appName = 'قرمشة';
  static const String tagline = 'مقرمش من أول لقمة';

  /// الرابط الأساسي للـ API.
  static const String baseUrl = 'https://dori.toldpath.com/api/v1';

  /// رابط المتجر (المطعم) على منصة دوري.
  static const String placeSlug = 'qarmasha';

  /// العملة الافتراضية إن لم يرجعها الـ API.
  static const String currencySymbol = '₪';

  /// مدة تجهيز الوجبة الافتراضية (بالدقائق) عند إضافتها من لوحة المالك.
  static const int defaultPrepMinutes = 15;

  /// عدد الطلبات التي يمكن تجهيزها لنفس الصنف في نفس الوقت.
  static const int defaultKitchenCapacity = 100;

  /// رسوم التوصيل.
  static const double deliveryFee = 10;

  /// عدد طاولات المطعم (لاختيار رقم الطاولة).
  static const int tablesCount = 30;
}
