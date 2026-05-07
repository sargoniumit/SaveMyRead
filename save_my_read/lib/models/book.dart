import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String author;

  @HiveField(2)
  String? review;

  @HiveField(3)
  List<String> imagePaths = [];

  @HiveField(4)
  int? rating;
}
