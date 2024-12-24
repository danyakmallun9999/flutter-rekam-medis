import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart'; // Pastikan file login_page.dart sudah ada

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Menonaktifkan banner debug
      home: LoginPage(), // Mengatur LoginPage sebagai halaman pertama
    );
  }
}

