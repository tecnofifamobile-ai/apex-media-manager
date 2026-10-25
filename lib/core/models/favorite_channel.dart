import 'package:isar/isar.dart';

part 'favorite_channel.g.dart';

@collection
class FavoriteChannel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String cleanName;

  late DateTime addedAt;
  
  String category = 'General';

  String? preferredUrl;
  String? preferredName;
}
