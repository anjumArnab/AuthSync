import 'package:flutter/material.dart';
import 'package:authsync/screens/homepage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuthSync',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme()
        ),
      home: HomePage(),
    );
  }
}

