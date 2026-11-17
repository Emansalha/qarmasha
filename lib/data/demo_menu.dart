import 'models.dart';

/// صور احترافية مجانية من Pexels (رخصة Pexels تسمح بالاستخدام التجاري).
String pexels(int id, {int w = 900}) =>
    'https://images.pexels.com/photos/$id/pexels-photo-$id.jpeg?auto=compress&cs=tinysrgb&w=$w';

/// صورة حقيقية مدمجة داخل التطبيق (assets/images) — تظهر فوراً وبدون إنترنت.
String img(String name) => 'assets/images/$name.jpg';

/// صورة حقيقية مناسبة لتصنيف حسب اسمه.
String categoryPhoto(String name) {
  if (name.contains('برجر') || name.contains('ساندو')) return img('cheeseburger');
  if (name.contains('مشروب') || name.contains('عصير')) return img('juices');
  if (name.contains('حلو') || name.contains('تحلية')) return img('choco_cake');
  if (name.contains('بطاط') || name.contains('جانب')) return img('fries');
  if (name.contains('سلط')) return img('salad');
  if (name.contains('وجب') || name.contains('كومبو')) return img('zinger_meal');
  return img('strips');
}

/// منيو احتياطي يظهر عند عدم توفر الاتصال أو قبل تفعيل متجر المطعم على دوري.
/// عند ربط المطعم تُستبدل هذه البيانات تلقائياً بأصناف دوري الحقيقية.
class DemoMenu {
  DemoMenu._();

  static final categories = <FoodCategory>[
    FoodCategory(id: 1, name: 'دجاج مقرمش', emoji: '🍗', imageUrl: img('strips')),
    FoodCategory(id: 2, name: 'برجر', emoji: '🍔', imageUrl: img('cheeseburger')),
    FoodCategory(id: 3, name: 'وجبات', emoji: '🍱', imageUrl: img('zinger_meal')),
    FoodCategory(id: 4, name: 'جانبيات', emoji: '🍟', imageUrl: img('fries')),
    FoodCategory(id: 5, name: 'مشروبات', emoji: '🥤', imageUrl: img('juices')),
    FoodCategory(id: 6, name: 'حلويات', emoji: '🍰', imageUrl: img('choco_cake')),
  ];

  static final banners = <PromoBanner>[
    PromoBanner(
      title: 'مقرمش. طازج.\nلا يُقاوَم.',
      subtitle: 'دجاج طازج 100% يُحضَّر عند الطلب',
      imageUrl: img('strips'),
    ),
    PromoBanner(
      title: 'خصم 30%\nعلى الوجبات',
      subtitle: 'على وجبات البرجر المختارة',
      imageUrl: img('banner_burger'),
      tag: 'عرض حصري',
    ),
    PromoBanner(
      title: 'حلّي\nعلى حسابنا',
      subtitle: 'تحلية مجانية مع كل طلب فوق 80 ₪',
      imageUrl: img('choco_cake'),
      tag: 'هذا الأسبوع',
    ),
  ];

  static final items = <MenuItem>[
    // دجاج مقرمش
    MenuItem(
      id: 101,
      name: 'ستربس مقرمش (8 قطع)',
      description:
          'شرائح صدر دجاج متبّلة بخلطتنا السرية، مغطاة بطبقة مقرمشة ذهبية ومقلية حتى الكمال. تُقدَّم مع صوصين حسب اختيارك.',
      price: 32,
      imageUrl: img('strips'),
      gallery: [img('strips'), img('neon_strips'), img('tenders')],
      categoryId: 1,
      categoryName: 'دجاج مقرمش',
      isFeatured: true,
      rating: 4.9,
      ordersCount: 1240,
      badge: 'الأكثر مبيعاً',
    ),
    MenuItem(
      id: 102,
      name: 'تندرز بصوص الشيدر',
      description:
          'قطع دجاج مقرمشة مغمورة بصوص الشيدر الذائب ورشة بابريكا مدخنة. وجبة غنية لعشاق الجبن.',
      price: 36,
      salePrice: 30,
      imageUrl: img('tenders'),
      gallery: [img('tenders'), img('strips')],
      categoryId: 1,
      categoryName: 'دجاج مقرمش',
      isFeatured: true,
      rating: 4.8,
      ordersCount: 860,
      badge: 'وفّر 17%',
    ),
    MenuItem(
      id: 103,
      name: 'أجنحة حارة مشوية',
      description:
          'أجنحة دجاج متبّلة بالبهارات الحارة والأعشاب، مشوية على الفحم حتى تتحمّر. 10 قطع مع صوص الثوم.',
      price: 34,
      imageUrl: img('wings'),
      gallery: [img('wings'), img('spicy_chicken')],
      categoryId: 1,
      categoryName: 'دجاج مقرمش',
      rating: 4.7,
      ordersCount: 640,
    ),
    MenuItem(
      id: 104,
      name: 'دجاج حار بالفلفل',
      description:
          'قطع دجاج مقلية ومقلّبة بصوص الفلفل الأحمر الحار والليمون والكزبرة. لمحبي الحرارة الحقيقية 🌶️',
      price: 38,
      imageUrl: img('spicy_chicken'),
      categoryId: 1,
      categoryName: 'دجاج مقرمش',
      rating: 4.6,
      ordersCount: 410,
      badge: 'حار جداً',
    ),
    MenuItem(
      id: 105,
      name: 'دجاجة كاملة مشوية',
      description:
          'دجاجة كاملة متبّلة لمدة 12 ساعة ومشوية ببطء حتى تصبح ذهبية وطرية من الداخل. تكفي 3-4 أشخاص.',
      price: 65,
      imageUrl: img('roast_chicken'),
      gallery: [img('roast_chicken'), img('whole_chicken')],
      categoryId: 1,
      categoryName: 'دجاج مقرمش',
      rating: 4.8,
      ordersCount: 520,
      prepMinutes: 25,
    ),

    // برجر
    MenuItem(
      id: 201,
      name: 'زنجر برجر مقرمش',
      description:
          'صدر دجاج مقرمش حار مع خس طازج وصوص المايونيز الخاص، داخل خبز بريوش محمّص.',
      price: 28,
      imageUrl: img('zinger'),
      gallery: [img('zinger'), img('zinger_meal')],
      categoryId: 2,
      categoryName: 'برجر',
      isFeatured: true,
      rating: 4.9,
      ordersCount: 1530,
      badge: 'رائج',
    ),
    MenuItem(
      id: 202,
      name: 'تشيز برجر لحم أنغوس',
      description:
          'قطعة لحم أنغوس مشوية على اللهب مع شريحتي جبن شيدر، طماطم، خس، مخلل وصوص البيت.',
      price: 35,
      imageUrl: img('cheeseburger'),
      gallery: [img('cheeseburger'), img('classic_burger')],
      categoryId: 2,
      categoryName: 'برجر',
      isFeatured: true,
      rating: 4.8,
      ordersCount: 980,
    ),
    MenuItem(
      id: 203,
      name: 'دبل برجر الشيف',
      description:
          'طبقتان من اللحم البقري مع جبن ذائب وبصل مكرمل وفلفل حار. للجوعانين فقط!',
      price: 45,
      imageUrl: img('double_burger'),
      categoryId: 2,
      categoryName: 'برجر',
      rating: 4.7,
      ordersCount: 450,
      badge: 'حجم كبير',
    ),
    MenuItem(
      id: 204,
      name: 'برجر كلاسيك',
      description:
          'برجر لحم طازج مع خس وطماطم وبصل وصوص الكاتشب والمسطردة. الطعم الأصلي اللي بتحبه.',
      price: 26,
      imageUrl: img('classic_burger'),
      categoryId: 2,
      categoryName: 'برجر',
      rating: 4.6,
      ordersCount: 720,
    ),

    // وجبات
    MenuItem(
      id: 301,
      name: 'وجبة زنجر + بطاطا + مشروب',
      description:
          'زنجر برجر مقرمش مع بطاطا مقلية وسط ومشروب غازي بارد. الوجبة المثالية للغداء.',
      price: 39,
      salePrice: 33,
      imageUrl: img('zinger_meal'),
      categoryId: 3,
      categoryName: 'وجبات',
      isFeatured: true,
      rating: 4.9,
      ordersCount: 2100,
      badge: 'وفّر 15%',
    ),
    MenuItem(
      id: 302,
      name: 'وجبة برجر وبطاطا',
      description:
          'تشيز برجر مع بطاطا مقرمشة وصوص الجبنة. وجبة متكاملة تشبع وتسعد.',
      price: 42,
      salePrice: 36,
      imageUrl: img('burger_fries'),
      categoryId: 3,
      categoryName: 'وجبات',
      rating: 4.8,
      ordersCount: 1320,
    ),
    MenuItem(
      id: 303,
      name: 'كلوب ساندويتش مع بطاطا',
      description:
          'ساندويتش ثلاث طبقات بالدجاج المدخن والجبن والبيض والخضار، مع بطاطا مقلية.',
      price: 34,
      imageUrl: img('club'),
      categoryId: 3,
      categoryName: 'وجبات',
      rating: 4.7,
      ordersCount: 530,
    ),
    MenuItem(
      id: 304,
      name: 'بوكس العائلة',
      description:
          'برجرين + 8 قطع ستربس + بطاطا عائلي + 4 صوصات + لتر مشروب. يكفي 4 أشخاص.',
      price: 119,
      salePrice: 99,
      imageUrl: img('family_box'),
      categoryId: 3,
      categoryName: 'وجبات',
      isFeatured: true,
      rating: 4.9,
      ordersCount: 890,
      badge: 'للعائلة',
      prepMinutes: 25,
    ),

    // جانبيات
    MenuItem(
      id: 401,
      name: 'بطاطا مقلية ذهبية',
      description: 'بطاطا مقطّعة طازجة ومقلية مرتين لقرمشة لا تُنسى، مع ملح البحر.',
      price: 12,
      imageUrl: img('fries'),
      gallery: [img('fries'), img('fries2')],
      categoryId: 4,
      categoryName: 'جانبيات',
      rating: 4.8,
      ordersCount: 3100,
    ),
    MenuItem(
      id: 402,
      name: 'بطاطا حلوة مع صوص',
      description: 'أصابع البطاطا الحلوة المقرمشة مع صوص الشيبوتلي المدخن.',
      price: 16,
      imageUrl: img('sweet_fries'),
      categoryId: 4,
      categoryName: 'جانبيات',
      rating: 4.7,
      ordersCount: 640,
    ),
    MenuItem(
      id: 403,
      name: 'حلقات بصل وناجتس',
      description: 'تشكيلة مقرمشة: حلقات بصل، ناجتس دجاج وبطاطا مع صوص الرانش.',
      price: 22,
      imageUrl: img('onion_rings'),
      categoryId: 4,
      categoryName: 'جانبيات',
      rating: 4.6,
      ordersCount: 470,
    ),
    MenuItem(
      id: 404,
      name: 'سلطة الدجاج المقرمش',
      description: 'خس روماني، طماطم كرزية، جبن بارميزان وقطع دجاج مقرمشة مع صوص السيزر.',
      price: 24,
      imageUrl: img('salad'),
      categoryId: 4,
      categoryName: 'جانبيات',
      rating: 4.6,
      ordersCount: 380,
    ),

    // مشروبات
    MenuItem(
      id: 501,
      name: 'موهيتو ليمون ونعناع',
      description: 'ليمون طازج ونعناع وثلج مجروش مع صودا منعشة.',
      price: 14,
      imageUrl: img('mojito'),
      categoryId: 5,
      categoryName: 'مشروبات',
      rating: 4.8,
      ordersCount: 900,
      prepMinutes: 5,
    ),
    MenuItem(
      id: 502,
      name: 'عصير برتقال طازج',
      description: 'برتقال معصور عند الطلب بدون إضافات.',
      price: 12,
      imageUrl: img('orange'),
      categoryId: 5,
      categoryName: 'مشروبات',
      rating: 4.7,
      ordersCount: 610,
      prepMinutes: 5,
    ),
    MenuItem(
      id: 503,
      name: 'عصير بطيخ',
      description: 'بطيخ أحمر بارد ومنعش، مثالي مع الوجبات الحارة.',
      price: 13,
      imageUrl: img('watermelon'),
      categoryId: 5,
      categoryName: 'مشروبات',
      rating: 4.6,
      ordersCount: 330,
      prepMinutes: 5,
    ),
    MenuItem(
      id: 504,
      name: 'مشروبات غازية',
      description: 'علبة باردة من مشروبك الغازي المفضّل.',
      price: 6,
      imageUrl: img('sodas'),
      categoryId: 5,
      categoryName: 'مشروبات',
      rating: 4.5,
      ordersCount: 2400,
      prepMinutes: 5,
    ),

    // حلويات
    MenuItem(
      id: 601,
      name: 'كيكة الشوكولاتة الفاخرة',
      description: 'طبقات من الكيك الإسفنجي بالشوكولاتة البلجيكية والكريمة الغنية.',
      price: 18,
      imageUrl: img('choco_cake'),
      categoryId: 6,
      categoryName: 'حلويات',
      isFeatured: true,
      rating: 4.9,
      ordersCount: 760,
      prepMinutes: 5,
    ),
    MenuItem(
      id: 602,
      name: 'تشيز كيك التوت',
      description: 'تشيز كيك نيويورك كريمي مع صوص التوت الأحمر الطازج.',
      price: 20,
      imageUrl: img('cheesecake'),
      categoryId: 6,
      categoryName: 'حلويات',
      rating: 4.8,
      ordersCount: 540,
      prepMinutes: 5,
    ),
    MenuItem(
      id: 603,
      name: 'براونيز بالشوكولاتة',
      description: 'براونيز طرية من الداخل مع قطع الشوكولاتة والتوت.',
      price: 15,
      imageUrl: img('brownies'),
      categoryId: 6,
      categoryName: 'حلويات',
      rating: 4.7,
      ordersCount: 480,
      prepMinutes: 5,
    ),
    MenuItem(
      id: 604,
      name: 'تارت الفواكه',
      description: 'تارت مقرمش بكريمة الفانيلا وتشكيلة فواكه موسمية.',
      price: 17,
      imageUrl: img('tart'),
      categoryId: 6,
      categoryName: 'حلويات',
      rating: 4.6,
      ordersCount: 210,
      prepMinutes: 5,
    ),
  ];

  /// صور جاهزة يمكن للمالك اختيارها عند إضافة صنف جديد.
  static final ownerGallery = <String, String>{
    'ستربس دجاج': img('strips'),
    'تندرز بالشيدر': img('tenders'),
    'أجنحة': img('wings'),
    'دجاج حار': img('spicy_chicken'),
    'دجاج مشوي': img('roast_chicken'),
    'زنجر': img('zinger'),
    'تشيز برجر': img('cheeseburger'),
    'دبل برجر': img('double_burger'),
    'وجبة زنجر': img('zinger_meal'),
    'برجر وبطاطا': img('burger_fries'),
    'بطاطا': img('fries'),
    'ناجتس وحلقات': img('onion_rings'),
    'سلطة': img('salad'),
    'موهيتو': img('mojito'),
    'برتقال': img('orange'),
    'كيكة شوكولاتة': img('choco_cake'),
    'تشيز كيك': img('cheesecake'),
    'براونيز': img('brownies'),
  };
}
