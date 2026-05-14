import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_shell.dart';
import 'core/di/injection.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await configureDependencies();
  await getIt<NotificationService>().init();

  // Ayarları uygulama başlarken yükle
  getIt<SettingsCubit>().load();

  runApp(const OpenQuitApp());
}

class OpenQuitApp extends StatelessWidget {
  const OpenQuitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // SettingsCubit tüm uygulama boyunca tek instance — her yerde erişilebilir
      value: getIt<SettingsCubit>(),
      child: MaterialApp(
        title: 'OpenQuit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const AppShell(),
      ),
    );
  }
}
