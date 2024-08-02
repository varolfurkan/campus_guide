class Club {
  final String id;
  final String title;
  final String description;
  final String img;
  final List<Map<String, dynamic>> events;
  final int members;
  final String type;
  final List<Map<String, dynamic>> management;
  final String contactInfo;

  Club({
    required this.id,
    required this.title,
    required this.description,
    required this.img,
    required this.events,
    required this.members,
    required this.type,
    required this.management,
    required this.contactInfo,
  });

  factory Club.fromMap(Map<String, dynamic> data) {
    return Club(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      img: data['img'] ?? '',
      events: List<Map<String, dynamic>>.from(data['events'] ?? []),
      members: data['members'] ?? 0,
      type: data['type'] ?? '',
      management: List<Map<String, dynamic>>.from(data['management'] ?? []),
      contactInfo: data['contactInfo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'img': img,
      'events': events,
      'members': members,
      'type': type,
      'management': management,
      'contactInfo': contactInfo,
    };
  }
}
