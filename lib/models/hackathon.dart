class Hackathon {
  final String id;
  final String name;
  final String? title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double teamFee;
  final int maxTeamSize;
  final int? maxTeams;
  final String status;

  Hackathon({
    required this.id,
    required this.name,
    this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.teamFee,
    required this.maxTeamSize,
    this.maxTeams,
    required this.status,
  });

  factory Hackathon.fromJson(Map<String, dynamic> json) {
    return Hackathon(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? '',
      title: json['title'],
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      teamFee: (json['team_fee'] ?? 0).toDouble(),
      maxTeamSize: json['max_team_size'] ?? 5,
      maxTeams: json['max_teams'],
      status: json['status'] ?? 'INACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title ?? name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'team_fee': teamFee,
      'max_team_size': maxTeamSize,
      'max_teams': maxTeams,
      'status': status,
    };
  }
}






