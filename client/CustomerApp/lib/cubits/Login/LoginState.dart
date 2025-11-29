
import 'package:customerapp/models/LoginUser.modal.dart';

class LoginState {

  LoginUser? loginUser;

  LoginState({this.loginUser});

  factory LoginState.initial() => LoginState(loginUser: 
      LoginUser(email: '', password: ''));
}