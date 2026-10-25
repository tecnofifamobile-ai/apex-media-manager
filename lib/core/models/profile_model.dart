enum ProfileType { m3u, xtreamCodes }

class Profile {
  final String id;
  final String name;
  final ProfileType type;
  final String? m3uUrl;
  final String? epgUrl;
  final String? xcUsername;
  final String? xcPassword;
  final String? xcUrl;
  final int colorCode;

  Profile({
    required this.id,
    required this.name,
    required this.type,
    this.m3uUrl,
    this.epgUrl,
    this.xcUsername,
    this.xcPassword,
    this.xcUrl,
    required this.colorCode,
  });

  // Factory simple para crear perfiles vacíos o copiarlos
  Profile copyWith({
    String? id,
    String? name,
    ProfileType? type,
    String? m3uUrl,
    String? epgUrl,
    String? xcUsername,
    String? xcPassword,
    String? xcUrl,
    int? colorCode,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      m3uUrl: m3uUrl ?? this.m3uUrl,
      xcUsername: xcUsername ?? this.xcUsername,
      xcPassword: xcPassword ?? this.xcPassword,
      xcUrl: xcUrl ?? this.xcUrl,
      colorCode: colorCode ?? this.colorCode,
    );
  }
}
