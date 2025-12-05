class SplashLogic {
  static const List<String> words = [
    "Welcome to Cinmeco Vendor",
    "Preparing your workspace",
    "Checking your inventory",
    "Optimizing your experience",
  ];

  static String getWord(int index) {
    return words[index % words.length];
  }
}
