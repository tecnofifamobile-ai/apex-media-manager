class Channel {
  final String name;
  final String url;
  final String group;
  final String logo;
  final String tvgId; // Para emparejar con el EPG

  Channel({
    required this.name,
    required this.url,
    this.group = '',
    this.logo = '',
    this.tvgId = '',
  });

  Channel copyWith({
    String? name,
    String? url,
    String? group,
    String? logo,
    String? tvgId,
  }) {
    return Channel(
      name: name ?? this.name,
      url: url ?? this.url,
      group: group ?? this.group,
      logo: logo ?? this.logo,
      tvgId: tvgId ?? this.tvgId,
    );
  }
}

class EpgProgram {
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String channelId;

  EpgProgram({
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.channelId = '',
  });

  double get progress {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;
    
    final total = end.difference(start).inSeconds;
    final current = now.difference(start).inSeconds;
    
    if (total <= 0) return 0.0;
    return current / total;
  }
}

class VodItem {
  final String id;
  final String name;
  final String streamIcon;
  final String streamType;
  final String containerExtension;
  final String categoryId;
  final double rating;

  VodItem({
    required this.id,
    required this.name,
    this.streamIcon = '',
    this.streamType = 'movie',
    this.containerExtension = 'mp4',
    this.categoryId = '',
    this.rating = 0.0,
  });
}

