// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:customerapp/cubits/SignUp/SignUpCubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should fail on invalid sign up credentials', () {
    final cubit = SignUpCubit();

    cubit.updateName('John Doe');
    expect(cubit.state.signupUser!.name, 'John Doe');

    cubit.updateEmail('johndoe@example.com');
    expect(cubit.state.signupUser!.email, 'johndoe@example.com');

    cubit.updatePassword('password123');
    expect(cubit.state.signupUser!.password, 'password123');

    cubit.updateConfirmPassword('password123');
    expect(cubit.state.signupUser!.confirmPassword, 'password123');

    expect(cubit.isSignupUserComplete(), true);

  });
 
}
