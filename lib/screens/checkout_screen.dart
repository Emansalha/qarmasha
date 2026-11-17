import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/api_service.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/animations.dart';
import '../widgets/icon3d.dart';
import '../widgets/table_picker.dart';
import 'auth/login_screen.dart';
import 'order_success_screen.dart';

/// إتمام الطلب:
/// - داخل المطعم ← اختيار رقم الطاولة.
/// - خارج المطعم ← توصيل للعنوان.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  OrderType _type = OrderType.dineIn;
  int? _table;
  String _payment = 'cash';
  bool _loading = false;
  bool _prefilled = false;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _street = TextEditingController();
  final _building = TextEditingController();
  final _notes = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.read(context);
    final user = state.user;
    if (!_prefilled) {
      _prefilled = true;
      _type = state.orderMode;
      _table = state.tableNumber;
      if (state.savedAddress.isNotEmpty) _city.text = state.savedAddress;
      if (user != null) {
        _name.text = user.name;
        _phone.text = user.phone;
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _city, _street, _building, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final state = AppScope.read(context);
    if (_type == OrderType.dineIn && _table == null) {
      _error('اختر رقم الطاولة أولاً');
      return;
    }
    if (!_form.currentState!.validate()) return;

    // طلب حقيقي على دوري يحتاج حساب عميل
    if (!state.usingDemoMenu && state.api.customerToken == null) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => const LoginScreen(popOnSuccess: true)),
      );
      if (ok != true || !mounted) return;
    }

    setState(() => _loading = true);
    try {
      final address = _type == OrderType.delivery
          ? [
              _city.text.trim(),
              _street.text.trim(),
              _building.text.trim(),
            ].where((e) => e.isNotEmpty).join('، ')
          : null;
      final order = await state.checkout(
        type: _type,
        customerName: _name.text.trim(),
        phone: _phone.text.trim(),
        tableNumber: _type == OrderType.dineIn ? _table : null,
        address: address,
        notes: _notes.text.trim(),
        paymentMethod: _payment,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        SmoothRoute<void>(builder: (_) => OrderSuccessScreen(order: order)),
        (route) => route.isFirst,
      );
    } on ApiException catch (e) {
      _error(e.message);
    } catch (_) {
      _error('تعذّر إرسال الطلب، تحقق من الاتصال وحاول مجدداً');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _error(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.primaryDark,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final fee = _type == OrderType.delivery ? AppConfig.deliveryFee : 0.0;
    final total = state.cartSubtotal + fee;

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const _Title('وين بدك تاكل؟'),
            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    icon: 'dinein',
                    title: 'داخل المطعم',
                    subtitle: 'برقم الطاولة',
                    selected: _type == OrderType.dineIn,
                    onTap: () {
                      setState(() => _type = OrderType.dineIn);
                      state.setOrderMode(OrderType.dineIn);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeCard(
                    icon: 'delivery',
                    title: 'توصيل',
                    subtitle: 'لباب البيت',
                    selected: _type == OrderType.delivery,
                    onTap: () {
                      setState(() => _type = OrderType.delivery);
                      state.setOrderMode(OrderType.delivery);
                    },
                  ),
                ),
              ],
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _type == OrderType.dineIn
                  ? _tablePicker()
                  : _addressForm(),
            ),

            const _Title('بيانات التواصل'),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                  hintText: 'الاسم', prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('user', size: 22))),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'أدخل اسمك' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                  hintText: 'رقم الهاتف',
                  prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('phone', size: 22))),
              validator: (v) => (v == null ||
                      !RegExp(r'^\+?[0-9\s-]{7,20}$').hasMatch(v.trim()))
                  ? 'رقم غير صحيح'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                  hintText: 'ملاحظات إضافية (اختياري)',
                  prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('note', size: 22))),
            ),

            const _Title('طريقة الدفع'),
            _PayOption(
              icon: 'cash',
              title: _type == OrderType.dineIn
                  ? 'نقداً عند الطاولة'
                  : 'نقداً عند الاستلام',
              selected: _payment == 'cash',
              onTap: () => setState(() => _payment = 'cash'),
            ),
            const SizedBox(height: 10),
            _PayOption(
              icon: 'card',
              title: 'بطاقة (تجريبي)',
              selected: _payment == 'card_demo',
              onTap: () => setState(() => _payment = 'card_demo'),
            ),

            const _Title('ملخص الطلب'),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: softShadow(),
              ),
              child: Column(
                children: [
                  for (final l in state.cart)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text('${l.quantity}×',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.optionsSummary.isEmpty
                                  ? l.item.name
                                  : '${l.item.name}\n${l.optionsSummary}',
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                          Text(money(l.total, state.currency)),
                        ],
                      ),
                    ),
                  const Divider(height: 20),
                  _sum('المجموع الفرعي',
                      money(state.cartSubtotal, state.currency)),
                  _sum(
                      'رسوم التوصيل',
                      fee == 0
                          ? 'مجاناً'
                          : money(fee, state.currency)),
                  const SizedBox(height: 6),
                  _sum('الإجمالي', money(total, state.currency), bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton(
            onPressed: _loading || state.cart.isEmpty ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Text('تأكيد الطلب • ${money(total, state.currency)}'),
          ),
        ),
      ),
    );
  }

  Widget _tablePicker() {
    return Column(
      key: const ValueKey('table'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Title('اختر رقم طاولتك'),
        const Text('تجد الرقم مكتوباً على طاولتك داخل المطعم',
            style: TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 12),
        TableGrid(
          selected: _table,
          onSelect: (n) {
            setState(() => _table = n);
            AppScope.read(context).setTable(n);
          },
        ),
        if (_table != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('✅ سيتم تقديم طلبك على الطاولة رقم $_table',
                style: const TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _addressForm() {
    String? req(String? v) =>
        (v == null || v.trim().isEmpty) ? 'حقل مطلوب' : null;
    return Column(
      key: const ValueKey('address'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Title('عنوان التوصيل'),
        TextFormField(
          controller: _city,
          decoration: const InputDecoration(
              hintText: 'المدينة / الحي',
              prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('pin', size: 22))),
          validator: req,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _street,
          decoration: const InputDecoration(
              hintText: 'الشارع وأقرب معلم',
              prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('pin', size: 22))),
          validator: req,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _building,
          decoration: const InputDecoration(
              hintText: 'العمارة / الطابق / الشقة (اختياري)',
              prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('home', size: 22))),
        ),
        const SizedBox(height: 8),
        Text(
            '🛵 رسوم التوصيل ${money(AppConfig.deliveryFee, AppScope.of(context).currency)} — الوقت المتوقع 30-45 دقيقة',
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }

  Widget _sum(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Text(a,
                style: TextStyle(
                    color: bold ? AppColors.text : AppColors.muted,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    fontSize: bold ? 17 : 14)),
            const Spacer(),
            Text(b,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
                    fontSize: bold ? 18 : 14,
                    color: bold ? AppColors.primary : AppColors.text)),
          ],
        ),
      );
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      );
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
          boxShadow: selected ? softShadow() : null,
        ),
        child: Column(
          children: [
            BounceIn(active: selected, child: Icon3D(icon, size: 44)),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: selected ? Colors.white : AppColors.text)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white70 : AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            IconTile(icon, size: 40),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
