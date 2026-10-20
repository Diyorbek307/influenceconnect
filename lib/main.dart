import 'package:flutter/material.dart';

import 'data/app_repository.dart';
import 'l10n/l10n.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await L10n.instance.init();
  await AppRepository.instance.init();
  runApp(const InfluenceConnectApp());
}

class InfluenceConnectApp extends StatelessWidget {
  const InfluenceConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Пересобираем всё приложение при смене языка.
    return ListenableBuilder(
      listenable: L10n.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'InfluenceConnect',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        );
      },
    );
  }
}
