import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/orientation_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  
  // Uygulama başlangıcında dikey mod zorla
  OrientationManager.forcePortrait();
  
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr', 'TR'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ben Kimim?',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
