class User {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String nationality;
  final String document;
  final String address;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.nationality = '',
    this.document = '',
    this.address = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: (json['role'] ?? 'USER').toString(),
      nationality: json['nationality'] ?? '',
      document: json['document'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'nationality': nationality,
    'document': document,
    'address': address,
  };
}
