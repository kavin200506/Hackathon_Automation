class Department {
  final String id;
  final String name;
  final String? collegeId;
  final String? collegeName;
  final int? teamCount;

  Department({
    required this.id,
    required this.name,
    this.collegeId,
    this.collegeName,
    this.teamCount,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      collegeId: json['college_id']?.toString(),
      collegeName: json['college_name'],
      teamCount: json['team_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'college_id': collegeId,
      'college_name': collegeName,
      'team_count': teamCount,
    };
  }
}




