import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'preview.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // أيقونات شريط الحالة فاتحة لأن التطبيق داكن
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  // بدل الشاشة السوداء/الرمادية عند أي خطأ: رسالة واضحة تساعد على معرفة السبب
  ErrorWidget.builder = (details) => Material(
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.primary, size: 48),
                    const SizedBox(height: 12),
                    const Text('صار خطأ بعرض هالشاشة',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(details.exceptionAsString(),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Qarmasha error: ${details.exceptionAsString()}');
  };
  final preview = kIsWeb ? Uri.base.queryParameters['screen'] : null;
  runApp(MyApp(state: AppState(), previewScreen: preview));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.state, this.previewScreen});

  final AppState state;
  final String? previewScreen;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // التطبيق بالكامل من اليمين لليسار
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: previewScreen == null
            ? const SplashScreen()
            : PreviewLauncher(screen: previewScreen!),
      ),
    );
  }
}
