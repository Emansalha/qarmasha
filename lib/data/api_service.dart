import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'models.dart';

/// خطأ مقروء من الـ API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? details;

  ApiException(this.message, {this.statusCode, this.code, this.details});

  @override
  String toString() => message;
}

/// نتيجة بيانات الصفحة الرئيسية.
class HomeData {
  final String? placeName;
  final String? coverUrl;
  final String currencySymbol;
  final bool openNow;
  final List<PromoBanner> banners;
  final List<FoodCategory> categories;
  final List<MenuItem> featured;
  final List<MenuItem> popular;

  HomeData({
    required this.banners,
    required this.categories,
    required this.featured,
    required this.popular,
    this.placeName,
    this.coverUrl,
    this.currencySymbol = AppConfig.currencySymbol,
    this.openNow = true,
  });
}

/// كل التعامل مع Dori API (https://dori.toldpath.com/docs).
///
/// - العميل: /places/{slug}/... (المنيو، التسجيل، الطلبات)
/// - المالك: /auth/login ثم /owner/services لإضافة أصناف بالصور.
class ApiService {
  ApiService({http.Client? client, this.slug = AppConfig.placeSlug})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String slug;

  String? customerToken;
  String? ownerToken;

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    return query == null ? uri : uri.replace(queryParameters: query);
  }

  Map<String, String> _headers({String? token, bool json = true}) => {
        if (json) 'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  dynamic _decode(http.Response res) {
    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {
      body = null;
    }
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (ok && (body == null || body['success'] != false)) {
      return body == null ? null : body['data'];
    }
    String message = body?['message']?.toString() ?? 'حدث خطأ غير متوقع';
    final error = body?['error'];
    Map<String, dynamic>? details;
    String? code;
    if (error is Map) {
      code = error['code']?.toString();
      if (error['details'] is Map) {
        details = Map<String, dynamic>.from(error['details'] as Map);
        // رسائل التحقق من الحقول
        final first = details.values.firstWhere(
          (v) => v is List && v.isNotEmpty,
          orElse: () => null,
        );
        if (first is List) message = first.first.toString();
      }
    }
    throw ApiException(message,
        statusCode: res.statusCode, code: code, details: details);
  }

  Future<dynamic> _get(String path,
      {Map<String, String>? query, String? token}) async {
    final res = await _client
        .get(_uri(path, query), headers: _headers(token: token))
        .timeout(const Duration(seconds: 20));
    return _decode(res);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body,
      {String? token}) async {
    final res = await _client
        .post(_uri(path),
            headers: _headers(token: token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 25));
    return _decode(res);
  }

  static List<Map<String, dynamic>> _list(dynamic data, [String? key]) {
    dynamic raw = data;
    if (raw is Map && key != null) raw = raw[key];
    if (raw is Map && raw['data'] is List) raw = raw['data'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // المنيو
  // ---------------------------------------------------------------------------

  /// GET /places/{slug}/home — كل ما تحتاجه الصفحة الرئيسية في طلب واحد.
  Future<HomeData> fetchHome() async {
    final data = await _get('/places/$slug/home');
    final place = data is Map ? data['place'] : null;
    String currency = AppConfig.currencySymbol;
    if (place is Map && place['currency_symbol'] != null) {
      currency = place['currency_symbol'].toString();
    }
    final featured = _list(data, 'featured').map(MenuItem.fromJson).toList();
    var popular = _list(data, 'popular').map(MenuItem.fromJson).toList();
    if (popular.isEmpty) {
      popular = _list(data, 'most_booked').map(MenuItem.fromJson).toList();
    }
    return HomeData(
      placeName: place is Map ? place['name']?.toString() : null,
      coverUrl: place is Map ? place['cover']?.toString() : null,
      currencySymbol: currency,
      openNow: place is Map ? place['open_now'] != false : true,
      banners: _list(data, 'banners').map(PromoBanner.fromJson).toList(),
      categories:
          _list(data, 'categories').map(FoodCategory.fromJson).toList(),
      featured: featured,
      popular: popular,
    );
  }

  /// GET /places/{slug}/services — أصناف المنيو (مع بحث وتصنيف).
  Future<List<MenuItem>> fetchMenu({int? categoryId, String? query}) async {
    final data = await _get('/places/$slug/services', query: {
      if (categoryId != null) 'category_id': '$categoryId',
      if (query != null && query.isNotEmpty) 'q': query,
      'sort': 'order',
    });
    return _list(data).map(MenuItem.fromJson).toList();
  }

  /// GET /places/{slug}/categories
  Future<List<FoodCategory>> fetchCategories() async {
    final data = await _get('/places/$slug/categories');
    return _list(data).map(FoodCategory.fromJson).toList();
  }

  // ---------------------------------------------------------------------------
  // حساب العميل
  // ---------------------------------------------------------------------------

  ({String token, AppUser user}) _authResult(dynamic data) {
    if (data is! Map) throw ApiException('رد غير متوقع من الخادم');
    final token =
        (data['token'] ?? data['access_token'] ?? '').toString();
    final userRaw = data['user'] ?? data['customer'] ?? data;
    return (
      token: token,
      user: AppUser.fromJson(Map<String, dynamic>.from(userRaw as Map)),
    );
  }

  Future<({String token, AppUser user})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _post('/places/$slug/auth/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'device_name': 'Qarmasha App',
    });
    final r = _authResult(data);
    customerToken = r.token;
    return r;
  }

  Future<({String token, AppUser user})> login({
    required String email,
    required String password,
  }) async {
    final data = await _post('/places/$slug/auth/login', {
      'email': email,
      'password': password,
      'device_name': 'Qarmasha App',
    });
    final r = _authResult(data);
    customerToken = r.token;
    return r;
  }

  Future<void> logout() async {
    if (customerToken == null) return;
    try {
      await _post('/places/$slug/auth/logout', {}, token: customerToken);
    } catch (_) {}
    customerToken = null;
  }

  // ---------------------------------------------------------------------------
  // الطلبات (حجوزات دوري)
  // ---------------------------------------------------------------------------

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// يبحث عن أول قيمة starts_at داخل رد الأوقات المتاحة.
  static String? _firstSlot(dynamic node) {
    if (node is Map) {
      final seats = node['seats_left'];
      final available = node['available'];
      if (node['starts_at'] != null &&
          available != false &&
          (seats == null || (seats is num && seats > 0))) {
        return node['starts_at'].toString();
      }
      for (final v in node.values) {
        final r = _firstSlot(v);
        if (r != null) return r;
      }
    } else if (node is List) {
      for (final v in node) {
        final r = _firstSlot(v);
        if (r != null) return r;
      }
    }
    return null;
  }

  /// أقرب وقت تجهيز متاح للصنف (اليوم أو خلال الأيام القادمة).
  Future<String> nextKitchenSlot(int serviceId) async {
    final now = DateTime.now();
    for (var i = 0; i < 3; i++) {
      final day = now.add(Duration(days: i));
      final data = await _get('/places/$slug/availability/slots', query: {
        'service_id': '$serviceId',
        'date': _date(day),
      });
      final slot = _firstSlot(data);
      if (slot != null) return slot;
    }
    throw ApiException('المطبخ مشغول حالياً، حاول بعد قليل');
  }

  /// يرسل الطلب: حجز واحد لكل صنف في السلة، مع نوع الطلب
  /// (طاولة / توصيل) في الملاحظات والإجابات.
  Future<List<int>> placeOrder({
    required String orderCode,
    required List<CartLine> lines,
    required OrderType type,
    required String customerName,
    required String phone,
    int? tableNumber,
    String? address,
    String notes = '',
    String paymentMethod = 'cash',
    String? couponCode,
  }) async {
    if (customerToken == null) {
      throw ApiException('يجب تسجيل الدخول أولاً');
    }
    final ids = <int>[];
    final where = type == OrderType.dineIn
        ? 'داخل المطعم - طاولة رقم $tableNumber'
        : 'توصيل إلى: $address';
    for (final line in lines) {
      final startsAt = await nextKitchenSlot(line.item.id);
      final noteText = [
        'طلب #$orderCode',
        where,
        'الكمية: ${line.quantity}',
        if (line.optionsSummary.isNotEmpty) 'الخيارات: ${line.optionsSummary}',
        if (line.note.isNotEmpty) 'ملاحظة الصنف: ${line.note}',
        if (notes.isNotEmpty) 'ملاحظات: $notes',
      ].join(' | ');
      final data = await _post(
        '/places/$slug/bookings',
        {
          'service_id': line.item.id,
          'starts_at': startsAt,
          'customer_name': customerName,
          'phone': phone,
          'notes': noteText.length > 500 ? noteText.substring(0, 500) : noteText,
          'answers': {
            'order_code': orderCode,
            'order_type': type.apiValue,
            'table_number': tableNumber,
            'delivery_address': address,
            'quantity': line.quantity,
          },
          if (couponCode != null && couponCode.isNotEmpty)
            'coupon_code': couponCode,
          'payment_method': paymentMethod,
        },
        token: customerToken,
      );
      final booking = data is Map && data['booking'] is Map
          ? data['booking'] as Map
          : (data is Map ? data : const {});
      final id = booking['id'];
      if (id is num) ids.add(id.toInt());
    }
    return ids;
  }

  /// GET /places/{slug}/bookings — حالة الطلبات من دوري.
  Future<Map<int, String>> fetchBookingStatuses() async {
    if (customerToken == null) return const {};
    final data = await _get('/places/$slug/bookings', token: customerToken);
    final map = <int, String>{};
    for (final b in _list(data)) {
      final id = b['id'];
      if (id is num) map[id.toInt()] = (b['status'] ?? '').toString();
    }
    return map;
  }

  /// POST /places/{slug}/coupons/check
  Future<double?> checkCoupon(String code, int serviceId) async {
    final data = await _post('/places/$slug/coupons/check',
        {'code': code, 'service_id': serviceId},
        token: customerToken);
    if (data is Map) {
      final v = data['final_price'] ?? data['price_after'] ?? data['discount'];
      if (v is num) return v.toDouble();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // لوحة المالك
  // ---------------------------------------------------------------------------

  Future<String> ownerLogin(String email, String password) async {
    final data = await _post('/auth/login', {
      'email': email,
      'password': password,
      'device_name': 'Qarmasha Owner',
    });
    final token = data is Map ? (data['token'] ?? '').toString() : '';
    if (token.isEmpty) throw ApiException('تعذّر تسجيل الدخول');
    ownerToken = token;
    return token;
  }

  Future<List<FoodCategory>> ownerCategories() async {
    final data = await _get('/owner/categories', token: ownerToken);
    return _list(data).map(FoodCategory.fromJson).toList();
  }

  Future<FoodCategory> ownerCreateCategory(String name) async {
    final data = await _post('/owner/categories',
        {'name': name, 'is_active': true}, token: ownerToken);
    final raw = data is Map && data['category'] is Map ? data['category'] : data;
    return FoodCategory.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<List<MenuItem>> ownerItems() async {
    final data = await _get('/owner/services', token: ownerToken);
    return _list(data).map(MenuItem.fromJson).toList();
  }

  /// تحميل صورة (من assets داخل التطبيق أو من رابط) لرفعها إلى دوري.
  Future<Uint8List> downloadImage(String url) async {
    if (url.startsWith('assets/')) {
      final data = await rootBundle.load(url);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    final res =
        await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 40));
    if (res.statusCode != 200) {
      throw ApiException('تعذّر تحميل الصورة من الرابط');
    }
    return res.bodyBytes;
  }

  /// POST /owner/services (multipart) — إضافة صنف جديد مع صوره.
  Future<MenuItem> ownerCreateItem({
    required String name,
    required String description,
    required double price,
    double? salePrice,
    int? categoryId,
    bool featured = false,
    int prepMinutes = AppConfig.defaultPrepMinutes,
    List<String> imageUrls = const [],
  }) async {
    final req = http.MultipartRequest('POST', _uri('/owner/services'));
    req.headers.addAll(_headers(token: ownerToken, json: false));
    req.fields.addAll({
      'name': name,
      'description': description,
      'price': price.toString(),
      if (salePrice != null) 'sale_price': salePrice.toString(),
      if (categoryId != null) 'category_id': '$categoryId',
      'duration_minutes': '$prepMinutes',
      'buffer_minutes': '0',
      'capacity': '${AppConfig.defaultKitchenCapacity}',
      'is_active': '1',
      'is_featured': featured ? '1' : '0',
    });
    var index = 0;
    for (final url in imageUrls) {
      final bytes = await downloadImage(url);
      index++;
      req.files.add(http.MultipartFile.fromBytes(
        'images[]',
        bytes,
        filename: 'food_$index.jpg',
      ));
    }
    final streamed =
        await _client.send(req).timeout(const Duration(seconds: 90));
    final res = await http.Response.fromStream(streamed);
    final data = _decode(res);
    final raw = data is Map && data['service'] is Map ? data['service'] : data;
    return MenuItem.fromJson(Map<String, dynamic>.from(raw as Map));
  }
}
