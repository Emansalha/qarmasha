/// النماذج الأساسية للتطبيق.
///
/// منصة دوري مبنية على "الخدمات" و"الحجوزات"؛ في تطبيق المطعم:
/// - كل صنف في المنيو = خدمة (service) في دوري.
/// - كل طلب = حجز (booking) لكل صنف، ومعه نوع الطلب (طاولة / توصيل) في الملاحظات والإجابات.
library;

import 'demo_menu.dart' show categoryPhoto;

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class FoodCategory {
  final int id;
  final String name;
  final String? imageUrl;
  final String emoji;

  const FoodCategory({
    required this.id,
    required this.name,
    this.imageUrl,
    this.emoji = '🍗',
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    return FoodCategory(
      id: _toInt(json['id']),
      name: name,
      imageUrl: (json['image'] == null || json['image'].toString().isEmpty)
          ? categoryPhoto(name)
          : json['image'].toString(),
      emoji: emojiFor(name),
    );
  }

  /// إيموجي مناسب حسب اسم التصنيف (لأن دوري يعيد أيقونات ويب).
  static String emojiFor(String name) {
    if (name.contains('برجر') || name.contains('ساندو')) return '🍔';
    if (name.contains('مشروب') || name.contains('عصير')) return '🥤';
    if (name.contains('حلو') || name.contains('تحلية')) return '🍰';
    if (name.contains('بطاط') || name.contains('جانب')) return '🍟';
    if (name.contains('سلط')) return '🥗';
    if (name.contains('وجب') || name.contains('كومبو')) return '🍱';
    return '🍗';
  }
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final String imageUrl;
  final List<String> gallery;
  final int? categoryId;
  final String? categoryName;
  final bool isFeatured;
  final double rating;
  final int ordersCount;
  final int prepMinutes;
  final String? badge;

  /// true إذا جاء الصنف من دوري (يمكن طلبه عبر الـ API).
  final bool fromApi;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.salePrice,
    this.gallery = const [],
    this.categoryId,
    this.categoryName,
    this.isFeatured = false,
    this.rating = 4.8,
    this.ordersCount = 0,
    this.prepMinutes = 15,
    this.badge,
    this.fromApi = false,
  });

  double get finalPrice =>
      (salePrice != null && salePrice! > 0 && salePrice! < price)
          ? salePrice!
          : price;

  bool get hasDiscount => finalPrice < price;

  int get discountPercent =>
      hasDiscount ? (((price - finalPrice) / price) * 100).round() : 0;

  List<String> get allImages =>
      gallery.isNotEmpty ? gallery : [if (imageUrl.isNotEmpty) imageUrl];

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final images = <String>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final img in rawImages) {
        if (img is Map && img['url'] != null) images.add(img['url'].toString());
        if (img is String) images.add(img);
      }
    }
    final category = json['category'];
    final sale = json['sale_price'];
    final rating = json['rating'];
    return MenuItem(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(json['price']),
      salePrice: sale == null ? null : _toDouble(sale),
      imageUrl: (json['image'] ?? (images.isNotEmpty ? images.first : ''))
          .toString(),
      gallery: images,
      categoryId: json['category_id'] == null
          ? (category is Map ? _toInt(category['id']) : null)
          : _toInt(json['category_id']),
      categoryName: category is Map ? category['name']?.toString() : null,
      isFeatured: json['is_featured'] == true,
      rating: rating is Map
          ? (_toDouble(rating['average']) == 0
              ? 4.8
              : _toDouble(rating['average']))
          : 4.8,
      ordersCount: _toInt(json['bookings_count']),
      prepMinutes: _toInt(json['duration_minutes']) == 0
          ? 15
          : _toInt(json['duration_minutes']),
      badge: json['is_featured'] == true ? 'الأكثر طلباً' : null,
      fromApi: true,
    );
  }
}

class CartLine {
  final MenuItem item;
  int quantity;
  String note;

  CartLine({required this.item, this.quantity = 1, this.note = ''});

  double get total => item.finalPrice * quantity;
}

enum OrderType { dineIn, delivery }

extension OrderTypeX on OrderType {
  String get label => this == OrderType.dineIn ? 'داخل المطعم' : 'توصيل';
  String get apiValue => this == OrderType.dineIn ? 'dine_in' : 'delivery';
}

enum OrderStatus { pending, preparing, onTheWay, served, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'بانتظار التأكيد',
        OrderStatus.preparing => 'قيد التحضير',
        OrderStatus.onTheWay => 'في الطريق إليك',
        OrderStatus.served => 'تم التقديم',
        OrderStatus.delivered => 'تم التوصيل',
        OrderStatus.cancelled => 'ملغي',
      };

  static OrderStatus fromApi(String? status, OrderType type) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
      case 'checked_in':
        return OrderStatus.preparing;
      case 'completed':
        return type == OrderType.dineIn
            ? OrderStatus.served
            : OrderStatus.delivered;
      case 'cancelled':
      case 'no_show':
      case 'rejected':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.preparing;
    }
  }
}

class PlacedOrder {
  final String code;
  final DateTime createdAt;
  final OrderType type;
  final int? tableNumber;
  final String? address;
  final String customerName;
  final String phone;
  final String notes;
  final String paymentMethod;
  final List<CartLine> lines;
  final double subtotal;
  final double deliveryFee;
  final List<int> bookingIds;
  OrderStatus status;

  PlacedOrder({
    required this.code,
    required this.createdAt,
    required this.type,
    required this.customerName,
    required this.phone,
    required this.lines,
    required this.subtotal,
    required this.deliveryFee,
    this.tableNumber,
    this.address,
    this.notes = '',
    this.paymentMethod = 'cash',
    this.bookingIds = const [],
    this.status = OrderStatus.pending,
  });

  double get total => subtotal + deliveryFee;

  String get destination => type == OrderType.dineIn
      ? 'طاولة رقم ${tableNumber ?? '-'}'
      : (address ?? '');

  Map<String, dynamic> toJson() => {
        'code': code,
        'created_at': createdAt.toIso8601String(),
        'type': type.apiValue,
        'table_number': tableNumber,
        'address': address,
        'customer_name': customerName,
        'phone': phone,
        'notes': notes,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'booking_ids': bookingIds,
        'status': status.name,
        'lines': lines
            .map((l) => {
                  'id': l.item.id,
                  'name': l.item.name,
                  'price': l.item.finalPrice,
                  'image': l.item.imageUrl,
                  'quantity': l.quantity,
                  'note': l.note,
                })
            .toList(),
      };

  factory PlacedOrder.fromJson(Map<String, dynamic> json) {
    final type =
        json['type'] == 'dine_in' ? OrderType.dineIn : OrderType.delivery;
    final lines = <CartLine>[];
    for (final raw in (json['lines'] as List? ?? const [])) {
      final m = Map<String, dynamic>.from(raw as Map);
      lines.add(CartLine(
        item: MenuItem(
          id: _toInt(m['id']),
          name: (m['name'] ?? '').toString(),
          description: '',
          price: _toDouble(m['price']),
          imageUrl: (m['image'] ?? '').toString(),
        ),
        quantity: _toInt(m['quantity']),
        note: (m['note'] ?? '').toString(),
      ));
    }
    return PlacedOrder(
      code: (json['code'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      type: type,
      tableNumber:
          json['table_number'] == null ? null : _toInt(json['table_number']),
      address: json['address']?.toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? 'cash').toString(),
      subtotal: _toDouble(json['subtotal']),
      deliveryFee: _toDouble(json['delivery_fee']),
      bookingIds: (json['booking_ids'] as List? ?? const [])
          .map((e) => _toInt(e))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      lines: lines,
    );
  }
}

class AppUser {
  final String name;
  final String email;
  final String phone;

  const AppUser({required this.name, required this.email, required this.phone});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'phone': phone};
}

class PromoBanner {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String tag;

  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.tag = 'لفترة محدودة',
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) => PromoBanner(
        title: (json['title'] ?? '').toString(),
        subtitle: (json['subtitle'] ?? json['description'] ?? '').toString(),
        imageUrl: (json['image'] ?? json['image_url'] ?? '').toString(),
      );
}
