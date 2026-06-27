import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/route/app_router.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await ServiceLocator().init();
  } catch (e) {
    // ignore: avoid_print
    print('ServiceLocator init error: $e');
  }

  runApp(const ProviderScope(child: AiPersianSecretaryApp()));
}

class AiPersianSecretaryApp extends ConsumerWidget {
  const AiPersianSecretaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);

    return MaterialApp.router(
      title: AppConstants.appNameEn,
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: appRouter,
    );
  }
}
