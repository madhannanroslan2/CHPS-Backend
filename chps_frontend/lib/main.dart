import 'package:flutter/material.dart';

import 'api_client.dart';
import 'pages/auth_page.dart';

class ChpsApp extends InheritedWidget {
  const ChpsApp({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  factory ChpsApp.of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChpsApp>()!;
  }

  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  @override
  bool updateShouldNotify(ChpsApp oldWidget) => themeMode != oldWidget.themeMode;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const defaultUrl = 'http://127.0.0.1:8000';
  final apiUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: defaultUrl);
  final api = ApiClient(apiUrl);

  runApp(MyApp(api: api));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.api});
  final ApiClient api;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChpsApp(
      themeMode: _themeMode,
      toggleTheme: toggleTheme,
      child: MaterialApp(
        title: 'CHPS Frontend',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
        themeMode: _themeMode,
        home: AuthPage(api: widget.api),
      ),
    );
  }
}
