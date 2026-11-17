import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../state/app_state.dart';
import '../../widgets/icon3d.dart';
import '../main_shell.dart';
import '../splash_screen.dart';
import 'register_screen.dart';

/// تسجيل دخول العميل (POST /places/{slug}/auth/login).
///
/// [popOnSuccess] = true عند فتحها من شاشة الدفع لترجع إليها بعد الدخول.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.popOnSuccess = false});
  final bool popOnSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _done() {
    if (widget.popOnSuccess) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppScope.read(context)
          .login(_email.text.trim(), _password.text);
      if (mounted) _done();
    } on ApiException catch (e) {
      _error(e.message);
    } catch (_) {
      _error('تعذّر الاتصال بالخادم، تحقق من الإنترنت');
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!widget.popOnSuccess)
            TextButton(
              onPressed: _done,
              child: const Text('تخطي',
                  style: TextStyle(color: AppColors.muted)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: AppLogo(size: 34)),
                const SizedBox(height: 32),
                Text('تسجيل الدخول',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('أهلاً من جديد 👋',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('سجّل دخولك لتتابع طلباتك وتطلب بسرعة.',
                    style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 28),
                const _Label('البريد الإلكتروني'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('mail', size: 22)),
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'أدخل بريداً صحيحاً'
                      : null,
                ),
                const SizedBox(height: 16),
                const _Label('كلمة المرور'),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Padding(padding: EdgeInsets.all(11), child: Icon3D('lock', size: 22)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'كلمة المرور قصيرة'
                      : null,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Text('دخول'),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                      if (ok == true && mounted) _done();
                    },
                    child: const Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'ما عندك حساب؟ ',
                          style: TextStyle(color: AppColors.muted)),
                      TextSpan(
                          text: 'أنشئ حساباً جديداً',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ])),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
}
