import 'package:flutter_test/flutter_test.dart';

import 'package:qarmasha/data/models.dart';

void main() {
  test('cart line total = price x quantity', () {
    const item = MenuItem(
      id: 1,
      name: 'وجبة تجريبية',
      description: '',
      price: 20,
      imageUrl: '',
    );
    final line = CartLine(item: item, quantity: 3);
    expect(line.total, 60);
  });

  test('sale price is used when present', () {
    const item = MenuItem(
      id: 2,
      name: 'عرض',
      description: '',
      price: 30,
      salePrice: 25,
      imageUrl: '',
    );
    expect(item.finalPrice, 25);
    expect(item.hasDiscount, isTrue);
  });
}
