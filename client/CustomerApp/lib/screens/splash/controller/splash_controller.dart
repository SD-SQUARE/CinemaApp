class SplashLogic {
  static const List<String> words = [
    "Welcome to Cinmeco",
    "Thank You for Choosing Us",
    "Verifying Your Account",
  ];

  static String getWord(int index) {
    return words[index % words.length];
  }
}
