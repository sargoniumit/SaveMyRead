import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:save_my_read/models/book.dart';
import 'package:save_my_read/models/statistics.dart';
import 'package:google_fonts/google_fonts.dart';

class YearlyStatsScreen extends StatefulWidget {
  const YearlyStatsScreen({super.key});

  @override
  State<YearlyStatsScreen> createState() => _YearlyStatsScreenState();
}

class _YearlyStatsScreenState extends State<YearlyStatsScreen> {
  late Box<Statistics> statsBox;
  late Box<Book> booksBox;

  @override
  void initState() {
    super.initState();
    statsBox = Hive.box<Statistics>('statistics');
    booksBox = Hive.box<Book>('books');
  }

  void _updateCount(String year, int delta) {
    final stats = statsBox.values.firstWhere(
      (s) => s.year == year,
      orElse: () => Statistics()..year = year..count = 0,
    );
    
    if (statsBox.values.any((s) => s.year == year)) {
      stats.count += delta;
      stats.save();
    } else {
      final newStats = Statistics()
        ..year = year
        ..count = delta > 0 ? delta : 0;
      statsBox.add(newStats);
    }
  }

  Future<void> _syncWithLibrary() async {
    final currentYear = DateTime.now().year.toString();
    final bookCount = booksBox.values.length;
    
    final existingStats = statsBox.values.firstWhere(
      (s) => s.year == currentYear,
      orElse: () => Statistics()..year = currentYear..count = 0,
    );
    
    if (statsBox.values.any((s) => s.year == currentYear)) {
      existingStats.count = bookCount;
      existingStats.save();
    } else {
      final newStats = Statistics()
        ..year = currentYear
        ..count = bookCount;
      statsBox.add(newStats);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synced: $bookCount books for $currentYear',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  void _addYear() {
    final currentYear = DateTime.now().year;
    final newYear = (currentYear + 1).toString();
    
    if (!statsBox.values.any((s) => s.year == newYear)) {
      final newStats = Statistics()
        ..year = newYear
        ..count = 0;
      statsBox.add(newStats);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yearly Stats',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncWithLibrary,
            tooltip: 'Sync with Library',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addYear,
            tooltip: 'Add Year',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: statsBox.listenable(),
        builder: (context, Box<Statistics> box, _) {
          final stats = box.values.toList()
            ..sort((a, b) => b.year.compareTo(a.year));

          if (stats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No stats yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a year or sync with library',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              final maxCount = stats.isEmpty ? 1 : stats.map((s) => s.count).reduce((a, b) => a > b ? a : b);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stat.year,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: stat.count > 0
                                    ? () => setState(() => _updateCount(stat.year, -1))
                                    : null,
                              ),
                              Text(
                                '${stat.count} books',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () => setState(() => _updateCount(stat.year, 1)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: maxCount > 0 ? stat.count / maxCount : 0,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8E44AD),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
