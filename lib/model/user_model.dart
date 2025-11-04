class User {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String role;

  var token;

  User({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uuid: json['uuid'] ?? '',
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
    );
  }
}
