import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/book.dart';
import 'models/statistics.dart';
import 'services/payment_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(StatisticsAdapter());

  // Clear old box if it exists with old schema
  if (Hive.isBoxOpen('books')) {
    await Hive.box<Book>('books').close();
    await Hive.deleteBoxFromDisk('books');
  }

  await Hive.openBox<Book>('books');
  await Hive.openBox('settings');
  await Hive.openBox<Statistics>('statistics');

  // Initialize premium setting if not exists
  final settingsBox = Hive.box('settings');
  if (!settingsBox.containsKey('isPremium')) {
    await settingsBox.put('isPremium', false);
  }

  // Initialize payment service
  final paymentService = PaymentService();
  await paymentService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveMyRead',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F5E7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB68D40),
          primary: const Color(0xFFB68D40),
          secondary: const Color(0xFF4F8A8B),
          surface: const Color(0xFF4F8A8B),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF4F8A8B),
          foregroundColor: const Color(0xFFF9F5E7),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: const Color(0xFFF9F5E7),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A3233),
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A3233),
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A3233),
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A3233),
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A3233),
          ),
          bodyLarge: GoogleFonts.fraunces(
            fontSize: 16,
            height: 1.5,
            color: const Color(0xFF1A3233),
          ),
          bodyMedium: GoogleFonts.fraunces(
            fontSize: 14,
            color: const Color(0xFF1A3233),
          ),
          bodySmall: GoogleFonts.fraunces(
            fontSize: 12,
            color: const Color(0xFF1A3233),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1A3233),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFB68D40),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB68D40),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.fraunces(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFFAF6EB),
          elevation: 1,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF1A3233),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
