class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String tel;
  String role;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.tel,
      required this.role});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      tel: json['tel'],
      role: json['role'],
    );
  }
}
