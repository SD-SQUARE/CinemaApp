import 'package:customerapp/cubits/Login/LoginState.dart';
import 'package:customerapp/models/LoginUser.modal.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.initial());

  void setLoginUser(LoginUser user) {
    emit(LoginState(loginUser: user));
  }

  void updateEmail(String email) =>
      setLoginUser(state.loginUser!.copyWith(email: email));

  void updatePassword(String password) =>
      setLoginUser(state.loginUser!.copyWith(password: password));

  void clearLoginUser() {
    emit(LoginState.initial());
  }

  Future<bool> loginWithEmailAndPassword() async {
    final user = state.loginUser;
    if (user == null) return false;

    if (!LoginUser.isValidEmail(user.email)) return false;
    if (!LoginUser.isValidPassword(user.password)) return false;

    final response = await SupabaseService.client.auth.signInWithPassword(
      email: user.email,
      password: user.password,
    );

    if (response.user != null) {
      return true;
    }

    return false;
  }
}
