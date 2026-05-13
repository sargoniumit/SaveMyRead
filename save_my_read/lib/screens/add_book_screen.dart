import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:save_my_read/models/book.dart';
import 'package:save_my_read/services/payment_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'book_detail_screen.dart';
import 'dart:io';

class AddBookScreen extends StatefulWidget {
  final Book? book;
  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _reviewController = TextEditingController();
  int? _rating;
  List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _reviewController.text = widget.book!.review ?? '';
      _rating = widget.book!.rating;
      _imagePaths = List.from(widget.book!.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'book_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${appDir.path}/$fileName';

    await File(photo.path).copy(savedPath);

    setState(() {
      _imagePaths.add(savedPath);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    // Check book limit for free users
    if (widget.book == null) {
      final settingsBox = Hive.box('settings');
      final isPremium = settingsBox.get('isPremium', defaultValue: false);
      final booksBox = Hive.box<Book>('books');

      if (!isPremium && booksBox.length >= 5) {
        _showPremiumDialog();
        return;
      }
    }

    if (widget.book != null) {
      widget.book!.title = _titleController.text.trim();
      widget.book!.author = _authorController.text.trim();
      widget.book!.review = _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim();
      widget.book!.imagePaths = _imagePaths;
      widget.book!.rating = _rating;
      await widget.book!.save();
    } else {
      final book = Book()
        ..title = _titleController.text.trim()
        ..author = _authorController.text.trim()
        ..review = _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim()
        ..imagePaths = _imagePaths
        ..rating = _rating;

      final box = Hive.box<Book>('books');
      await box.add(book);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showPremiumDialog() {
    final paymentService = PaymentService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF9F5E7),
        title: Text(
          'Premium Required',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F8A8B),
          ),
        ),
        content: Text(
          'You have reached the limit of 5 free books. Purchase Lifetime access for unlimited books.',
          style: GoogleFonts.fraunces(
            fontSize: 16,
            color: const Color(0xFF1A3233),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.fraunces(
                color: const Color(0xFF1A3233),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await paymentService.buyPremium();
              if (success && context.mounted) {
                Navigator.pop(context);
                _saveBook();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB68D40),
            ),
            child: Text(
              'Purchase',
              style: GoogleFonts.fraunces(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book != null ? 'Edit Book' : 'Add Book'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_imagePaths.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagePaths.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imagePaths[index]),
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: 'Review',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                const Text('Rating:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < (_rating ?? 0) ? Icons.star : Icons.star_border,
                        color: const Color(0xFFB68D40),
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Book Photo'),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveBook,
            child: const Text('Save Book'),
          ),
        ),
      ),
    );
  }
}
