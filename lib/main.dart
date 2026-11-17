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
