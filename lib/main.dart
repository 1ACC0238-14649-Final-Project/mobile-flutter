import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'presentation/app_navigation.dart';
import 'ui.theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const UserAuthApp());
}

class UserAuthApp extends StatelessWidget {
  const UserAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Auth',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: const AppNavigation(),
    );
  }
}
