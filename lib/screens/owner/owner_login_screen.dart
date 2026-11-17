import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../state/app_state.dart';
import '../../widgets/icon3d.dart';
import 'owner_dashboard_screen.dart';

/// دخول صاحب المطعم (POST /auth/login) لإدارة المنيو.
class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await AppScope.read(context)
          .api
          .ownerLogin(_email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()));
    } on ApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('تعذّر الاتصال بالخادم');
    } finally {
      if (mounted) setState(() => _loading = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة صاحب المطعم')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.storefront_rounded,
              size: 70, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text('أدر منيو مطعمك',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'سجّل الدخول بحساب صاحب المتجر على منصة دوري\n(${AppConfig.placeSlug})',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
                hintText: 'البريد الإلكتروني',
                prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('mail', size: 22))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
                hintText: 'كلمة المرور', prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('lock', size: 22))),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : const Text('دخول'),
          ),
        ],
      ),
    );
  }
}
