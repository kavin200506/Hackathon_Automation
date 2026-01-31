class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? mobile;
  final String? college;
  final String? collegeId;
  final String? department;
  final String? departmentId;
  final String? registerNumber;
  final String? degree;
  final String? passedOutYear;
  final String? address;
  final String? tpoName;
  final String? contactNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.mobile,
    this.college,
    this.collegeId,
    this.department,
    this.departmentId,
    this.registerNumber,
    this.degree,
    this.passedOutYear,
    this.address,
    this.tpoName,
    this.contactNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      mobile: json['mobile'],
      college: json['college'],
      collegeId: json['college_id']?.toString(),
      department: json['department'],
      departmentId: json['department_id']?.toString(),
      registerNumber: json['register_number'],
      degree: json['degree'],
      passedOutYear: json['passed_out_year']?.toString(),
      address: json['address'],
      tpoName: json['tpo_name'],
      contactNumber: json['contact_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'college': college,
      'college_id': collegeId,
      'department': department,
      'department_id': departmentId,
      'register_number': registerNumber,
      'degree': degree,
      'passed_out_year': passedOutYear,
      'address': address,
      'tpo_name': tpoName,
      'contact_number': contactNumber,
    };
  }
}






