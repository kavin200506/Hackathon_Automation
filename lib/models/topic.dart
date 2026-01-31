class Topic {
  final String id;
  final String name;
  final String? description;
  final String? hackathonId;

  Topic({
    required this.id,
    required this.name,
    this.description,
    this.hackathonId,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      hackathonId: json['hackathon_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hackathon_id': hackathonId,
    };
  }
}






