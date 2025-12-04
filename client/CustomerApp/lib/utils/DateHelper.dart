import 'package:intl/intl.dart';

class Datehelper {
  static String dateLabel(DateTime dt) =>
      DateFormat('EEE, d MMM').format(dt); // Mon, 1 Dec

  static String timeLabel(DateTime dt) =>
      DateFormat('hh:mm a').format(dt); // 07:39 PM
}
