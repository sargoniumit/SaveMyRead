import 'package:hive/hive.dart';

part 'statistics.g.dart';

@HiveType(typeId: 1)
class Statistics extends HiveObject {
  @HiveField(0)
  late String year;

  @HiveField(1)
  late int count;
}
