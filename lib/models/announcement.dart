class Announcement {
  final String id;
  final String title;
  final String message;
  final String? priority;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.priority,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

