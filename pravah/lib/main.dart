import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pravah/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF003554), // Dark blue (Buttons, Containers)
          secondary: Colors.greenAccent[400]!, // Accent Color
          background: const Color(0xFF00263A), // Dark background
          surface: Colors.grey[850]!, // Card/Container background
          onPrimary: Colors.white, // Text on primary color
          onSecondary: Colors.black, // Text on secondary color
          onBackground: Colors.white, // Default text color
          onSurface: Colors.white, // Text on containers
        ),
        scaffoldBackgroundColor: const Color(0xFF00263A), // Global Background
        fontFamily: 'Montserrat', // Apply globally
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.montserrat(color: Colors.white),
          bodyMedium: GoogleFonts.montserrat(color: Colors.white70),
          bodySmall: GoogleFonts.montserrat(color: Colors.white60),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200], // Light grey input fields
          hintStyle: GoogleFonts.montserrat(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.greenAccent[400]!),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003554), // Button color
            foregroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}
