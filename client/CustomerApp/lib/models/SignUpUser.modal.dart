class SignUpUser {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  SignUpUser({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory SignUpUser.fromJson(Map<String, dynamic> json) {
    return SignUpUser(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
    );
  }

  @override
  String toString() {
    return 'SignUpUser {name: $name, email: $email, password: $password, confirmPassword: $confirmPassword}';
  }

  SignUpUser copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return SignUpUser(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  static bool isValidEmail(email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  static bool isValidPassword(password) =>
      password.length >= 8 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]')) &&
      password.contains(RegExp(r'[0-9]'));
  bool doPasswordsMatch() => password == confirmPassword;
}
