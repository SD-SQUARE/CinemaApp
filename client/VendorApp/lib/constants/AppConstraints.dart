import 'package:flutter/material.dart';

class Appconstraints {
  static const double appPadding = 18.0;
  static const double appPaddingSmall = 12.0;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
}
