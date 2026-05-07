import 'package:hive/hive.dart';

part 'favorite.g.dart';

@HiveType(typeId: 0)
class Favorite extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String thumbnail;

  Favorite({required this.id, required this.name, required this.thumbnail});
}