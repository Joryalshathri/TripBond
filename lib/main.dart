import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const TripBondApp(),
    ),
  );
}

class TripBondApp extends StatelessWidget {
  const TripBondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripBond',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4675B8),
          primary: const Color(0xFF4675B8),
          secondary: const Color(0xFFC8A858),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.mulishTextTheme(),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
