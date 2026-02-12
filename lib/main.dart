import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'stores/user_store.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

// Simple localization loader - loads JSON from assets and provides string map
class SimpleLocalizations {
  final Locale locale;
  Map<String, dynamic> _data = {};
  SimpleLocalizations(this.locale);
  static Future<SimpleLocalizations> load(Locale locale) async {
    final sl = SimpleLocalizations(locale);
    final path = 'assets/i18n/${locale.languageCode}.json';
    try {
      final raw = await rootBundle.loadString(path);
      sl._data = Map<String, dynamic>.from(jsonDecode(raw));
    } catch (_) {
      sl._data = {};
    }
    return sl;
  }

  String t(String key) => _data[key] ?? key;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userStore = UserStore();
  await userStore.init();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => userStore)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Locale _locale = const Locale('pt');
  SimpleLocalizations? loc;

  @override
  void initState() {
    super.initState();
    _loadLoc();
  }

  Future<void> _loadLoc() async {
    final loaded = await SimpleLocalizations.load(_locale);
    setState(() {
      loc = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesyn App',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      onGenerateRoute: RouteGenerator.generate,
      initialRoute: '/',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt'), Locale('es')],
      locale: _locale,
    );
  }
}
