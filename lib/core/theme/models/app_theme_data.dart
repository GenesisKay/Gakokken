import 'package:hive_ce/hive.dart';

part 'app_theme_data.g.dart';

@HiveType(typeId: 30)
class AppThemeData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isSystem;

  @HiveField(4)
  final Map<String, int> colors;

  AppThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.isSystem,
    required this.colors,
  });
}
