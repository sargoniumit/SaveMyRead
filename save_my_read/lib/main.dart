import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/book.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());

  // Clear old box if it exists with old schema
  if (Hive.isBoxOpen('books')) {
    await Hive.box<Book>('books').close();
    await Hive.deleteBoxFromDisk('books');
  }

  await Hive.openBox<Book>('books');
  await Hive.openBox('settings');

  // Initialize premium setting if not exists
  final settingsBox = Hive.box('settings');
  if (!settingsBox.containsKey('isPremium')) {
    await settingsBox.put('isPremium', false);
  }

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
        scaffoldBackgroundColor: const Color(0xFFF4EBD0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD2691E),
          primary: const Color(0xFFD2691E),
          secondary: const Color(0xFFA8BBA2),
          surface: const Color(0xFFA8BBA2),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFA8BBA2),
          foregroundColor: const Color(0xFF122620),
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF122620),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF122620),
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF122620),
          ),
          displaySmall: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF122620),
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF122620),
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF122620),
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF122620),
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF122620),
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF122620),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF122620),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD2691E),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD2691E),
            foregroundColor: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFE8DFC5),
          elevation: 2,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF122620),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
