import 'package:isar/isar.dart';

part 'isar_profile.g.dart';

@collection
class IsarProfile {
  Id id = Isar.autoIncrement; // Auto-increment ID local

  @Index(unique: true, replace: true)
  late String syncId; // ID que viene de Supabase (UUID)

  late String userId;
  late String name;
  late String type; // 'm3u' or 'xtreamCodes'

  String? m3uUrl;

  String? xcUsername;
  String? xcPassword;
  String? xcUrl;

  late int colorCode;

  DateTime? createdAt;
}
