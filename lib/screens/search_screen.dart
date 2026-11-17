import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/icon3d.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  static const _suggestions = [
    'دجاج',
    'برجر',
    'زنجر',
    'بطاطا',
    'حار',
    'شوكولاتة',
    'عصير',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final results = state.search(_query);
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        actions: const [
          Padding(padding: EdgeInsets.only(left: 16), child: CartButton())
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'ابحث عن وجبتك المفضّلة...',
                prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('search', size: 22)),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const Text('عمليات بحث شائعة',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in _suggestions)
                            ActionChip(
                              label: Text(s),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                              onPressed: () {
                                _controller.text = s;
                                setState(() => _query = s);
                              },
                            ),
                        ],
                      ),
                    ],
                  )
                : results.isEmpty
                    ? const Center(
                        child: Text('ما لقينا نتائج 😕 جرّب كلمة ثانية',
                            style: TextStyle(color: AppColors.muted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: results.length,
                        itemBuilder: (_, i) => FoodTile(item: results[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
