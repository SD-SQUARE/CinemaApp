import 'package:customerapp/cubits/SignUp/SignUpState.dart';
import 'package:customerapp/services/supabase_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/SignUpUser.modal.dart';

class SignUpCubit extends Cubit<SignupState> {
  SignUpCubit() : super(SignupState.initial());

  void updateSignupUser(SignUpUser signupUser) {
    emit(SignupState(signupUser: signupUser));
  }

  void updateName(String name) =>
      updateSignupUser(state.signupUser!.copyWith(name: name));
  void updateEmail(String email) =>
      updateSignupUser(state.signupUser!.copyWith(email: email));
  void updatePassword(String password) =>
      updateSignupUser(state.signupUser!.copyWith(password: password));
  void updateConfirmPassword(String confirmPassword) => updateSignupUser(
    state.signupUser!.copyWith(confirmPassword: confirmPassword),
  );

  Future<bool> signUpWithEmailAndPassword() async {
    final user = state.signupUser;
    if (user == null) return false;

    if (!SignUpUser.isValidEmail(user.email)) return false;
    if (!SignUpUser.isValidPassword(user.password)) return false;
    if (!user.doPasswordsMatch()) return false;

    final response = await SupabaseService.client.auth.signUp(
      email: user.email,
      password: user.password,
    );

    if (response.user != null) {
      // add user to customer table
      final customerResponse = await SupabaseService.client
          .from('customers')
          .insert({'uid': response.user!.id, 'name': user.name})
          .select()
          .single();

      print(customerResponse.toString());
      if (customerResponse.isEmpty) {
        return false;
      }
      return true;
    }

    return false;
  }

  void clearSignupUser() {
    emit(SignupState.initial());
  }

  bool isSignupUserComplete() {
    final user = state.signupUser;
    if (user == null) return false;

    return user.name.isNotEmpty &&
        user.email.isNotEmpty &&
        user.password.isNotEmpty &&
        user.confirmPassword.isNotEmpty;
  }
}
