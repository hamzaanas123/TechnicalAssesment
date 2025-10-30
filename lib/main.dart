import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: themeProv.currentTheme,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        brightness: Brightness.dark,
      ),
      home: const ProductListScreen(),
    );
  }
}
