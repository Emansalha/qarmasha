import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../data/demo_menu.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

/// إضافة صنف جديد للمنيو على دوري (POST /owner/services) مع صور احترافية.
class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _sale = TextEditingController();
  final _url = TextEditingController();
  final _newCategory = TextEditingController();

  final List<String> _images = [];
  List<FoodCategory> _categories = [];
  int? _categoryId;
  bool _featured = false;
  int _prep = AppConfig.defaultPrepMinutes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final c = await AppScope.read(context).api.ownerCategories();
      if (mounted) setState(() => _categories = c);
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _price, _sale, _url, _newCategory]) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleImage(String url) {
    setState(() {
      if (!_images.remove(url)) {
        if (_images.length >= 4) {
          _snack('يمكن اختيار 4 صور كحد أقصى');
          return;
        }
        _images.add(url);
      }
    });
  }

  Future<void> _addCategory() async {
    final name = _newCategory.text.trim();
    if (name.isEmpty) return;
    try {
      final c = await AppScope.read(context).api.ownerCreateCategory(name);
      if (!mounted) return;
      setState(() {
        _categories = [..._categories, c];
        _categoryId = c.id;
        _newCategory.clear();
      });
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_images.isEmpty) {
      _snack('اختر صورة واحدة على الأقل للصنف');
      return;
    }
    setState(() => _saving = true);
    try {
      await AppScope.read(context).api.ownerCreateItem(
            name: _name.text.trim(),
            description: _desc.text.trim(),
            price: double.parse(_price.text.trim()),
            salePrice: _sale.text.trim().isEmpty
                ? null
                : double.tryParse(_sale.text.trim()),
            categoryId: _categoryId,
            featured: _featured,
            prepMinutes: _prep,
            imageUrls: _images,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        content: Text('تمت إضافة الصنف بنجاح ✅'),
      ));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('تعذّر حفظ الصنف: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final gallery = DemoMenu.ownerGallery.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('صنف جديد')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const _H('صور الصنف'),
            const Text('اختر من صور احترافية جاهزة أو الصق رابط صورة',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final e = gallery[i];
                  final url = pexels(int.parse(
                      RegExp(r'photos/(\d+)/').firstMatch(e.value)!.group(1)!),
                      w: 1200);
                  final selected = _images.contains(url);
                  return GestureDetector(
                    onTap: () => _toggleImage(url),
                    child: Stack(
                      children: [
                        NetImage(e.value, width: 100, height: 110, radius: 16),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 3),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xAA000000)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 8,
                          left: 8,
                          child: Text(e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if (selected)
                          const Positioned(
                            top: 6,
                            left: 6,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.check,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _url,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                        hintText: 'https://... رابط صورة',
                        prefixIcon: Icon(Icons.link)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () {
                    final u = _url.text.trim();
                    if (u.startsWith('http')) {
                      _toggleImage(u);
                      _url.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_images.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('تم اختيار ${_images.length} صورة (الأولى هي الرئيسية)',
                  style: const TextStyle(
                      color: AppColors.success, fontSize: 12)),
            ],

            const _H('بيانات الصنف'),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(hintText: 'اسم الصنف'),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'أدخل الاسم' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _desc,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'الوصف (المكونات، الحجم...)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'السعر'),
                    validator: (v) => double.tryParse(v?.trim() ?? '') == null
                        ? 'سعر غير صحيح'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sale,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(hintText: 'سعر العرض (اختياري)'),
                  ),
                ),
              ],
            ),

            const _H('التصنيف'),
            DropdownButtonFormField<int?>(
              value: _categoryId,
              decoration: const InputDecoration(),
              hint: const Text('بدون تصنيف'),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('بدون تصنيف')),
                for (final c in _categories)
                  DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategory,
                    decoration: const InputDecoration(
                        hintText: 'تصنيف جديد (مثلاً: برجر)'),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: _addCategory, child: const Text('إضافة')),
              ],
            ),

            const _H('وقت التحضير'),
            Wrap(
              spacing: 8,
              children: [
                for (final m in const [5, 10, 15, 20, 30])
                  ChoiceChip(
                    label: Text('$m د'),
                    selected: _prep == m,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: _prep == m ? Colors.white : AppColors.text),
                    onSelected: (_) => setState(() => _prep = m),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text('صنف مميز (يظهر في الرئيسية)'),
              value: _featured,
              onChanged: (v) => setState(() => _featured = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white)),
                        SizedBox(width: 12),
                        Text('جاري رفع الصور والحفظ...'),
                      ],
                    )
                  : const Text('حفظ الصنف'),
            ),
          ],
        ),
      ),
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );
}
