class LoginUser {
  final String email;
  final String password;

  LoginUser({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(email: json['email'], password: json['password']);
  }

  @override
  String toString() {
    return 'LoginUser { email: $email, password: $password}';
  }

  LoginUser copyWith({String? email, String? password}) {
    return LoginUser(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  static bool isValidEmail(email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  static bool isValidPassword(password) =>
      password.length >= 8 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]')) &&
      password.contains(RegExp(r'[0-9]'));
}
