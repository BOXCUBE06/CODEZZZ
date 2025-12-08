// 1. THE COMMON USER
class User {
  final int id;
  final String loginId;
  final String name;
  final String role;
  final String? phoneNumber;
  final String status;

  User({
    required this.id,
    required this.loginId,
    required this.name,
    required this.role,
    this.phoneNumber,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      loginId: json['login_id'],
      name: json['name'],
      role: json['role'],
      phoneNumber: json['phone_number'],
      status: json['status'] ?? 'active',
    );
  }
}

class StudentDetails {
  final String department;
  final String yearLevel;

  StudentDetails({required this.department, required this.yearLevel});

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      department: json['department'] ?? 'Unknown',
      yearLevel: json['year_level'].toString(),
    );
  }
}

class ResponderDetails {
  final String position;

  ResponderDetails({required this.position});

  factory ResponderDetails.fromJson(Map<String, dynamic> json) {
    return ResponderDetails(
      position: json['position'] ?? 'Volunteer',
    );
  }
}
