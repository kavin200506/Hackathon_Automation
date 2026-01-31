class College {
  final String id;
  final String name;
  final String email;
  final String? contactNumber;
  final String? address;
  final String? tpoName;
  final int? departmentCount;
  final int? teamCount;

  College({
    required this.id,
    required this.name,
    required this.email,
    this.contactNumber,
    this.address,
    this.tpoName,
    this.departmentCount,
    this.teamCount,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'],
      address: json['address'],
      tpoName: json['tpo_name'],
      departmentCount: json['department_count'],
      teamCount: json['team_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact_number': contactNumber,
      'address': address,
      'tpo_name': tpoName,
      'department_count': departmentCount,
      'team_count': teamCount,
    };
  }
}






