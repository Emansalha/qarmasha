import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/api_service.dart';
import '../../state/app_state.dart';
import '../../widgets/icon3d.dart';

/// إنشاء حساب عميل (POST /places/{slug}/auth/register).
/// تُرجع true عند النجاح.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppScope.read(context).register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
      );
      if (mounted) Navigator.pop(context, true);
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String icon,
    String? hint,
    TextInputType? type,
    bool obscure = false,
    bool ltr = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: type,
            obscureText: obscure,
            textDirection: ltr ? TextDirection.ltr : null,
            decoration:
                InputDecoration(
                hintText: hint,
                prefixIcon: Padding(
                    padding: const EdgeInsets.all(11),
                    child: Icon3D(icon, size: 22))),
            validator: validator,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب جديد')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('خلّينا نتعرّف عليك 🍗',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('بياناتك تساعدنا نوصل طلبك بسرعة.',
                    style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 24),
                _field(
                  label: 'الاسم الكامل',
                  controller: _name,
                  icon: 'user',
                  hint: 'مثال: ليان خالد',
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'أدخل اسمك'
                      : null,
                ),
                _field(
                  label: 'رقم الهاتف',
                  controller: _phone,
                  icon: 'phone',
                  hint: '0599 123 456',
                  type: TextInputType.phone,
                  ltr: true,
                  validator: (v) => (v == null ||
                          !RegExp(r'^\+?[0-9\s-]{7,20}$').hasMatch(v.trim()))
                      ? 'رقم غير صحيح'
                      : null,
                ),
                _field(
                  label: 'البريد الإلكتروني',
                  controller: _email,
                  icon: 'mail',
                  hint: 'name@example.com',
                  type: TextInputType.emailAddress,
                  ltr: true,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'أدخل بريداً صحيحاً'
                      : null,
                ),
                _field(
                  label: 'كلمة المرور',
                  controller: _password,
                  icon: 'lock',
                  hint: '8 أحرف على الأقل (حروف وأرقام)',
                  obscure: true,
                  validator: (v) => (v == null || v.length < 8)
                      ? '8 أحرف على الأقل'
                      : null,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Text('إنشاء الحساب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
