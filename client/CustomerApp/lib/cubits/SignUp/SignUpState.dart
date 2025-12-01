import 'package:customerapp/models/SignUpUser.modal.dart';

class SignupState {
  SignUpUser? signupUser;

  SignupState({this.signupUser});

  factory SignupState.initial() {
    return SignupState(signupUser: SignUpUser(
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
    ),);
  }
}
