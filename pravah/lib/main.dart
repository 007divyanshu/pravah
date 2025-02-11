import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pravah/pages/home_page.dart';
import 'firebase_options.dart';

//firebaese binding
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //global theme
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 0, 48, 72),
          secondary: Color.fromARGB(255, 16, 197, 88),
          surface: Color.fromARGB(255, 2, 37, 55),
          onPrimary: Color.fromARGB(255, 250, 249, 233),
          onSecondary: Color.fromARGB(255, 250, 249, 233),
          onSurface: Color.fromARGB(255, 250, 249, 233),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 48, 72),
        fontFamily: 'Montserrat', // Apply globally
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.montserrat(color: Colors.white),
          bodyMedium: GoogleFonts.montserrat(color: Colors.white70),
          bodySmall: GoogleFonts.montserrat(color: Colors.white60),
        ),
      ),
      debugShowCheckedModeBanner: false,

      //dashboard
      home: HomePage(),
    );
  }
}
