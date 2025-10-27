import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 회원가입 플로우 상태 관리
class SignupFlowState {
  final String? email;
  final String? password;
  final String? nickname;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final List<String>? allergies;

  SignupFlowState({
    this.email,
    this.password,
    this.nickname,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.allergies,
  });

  SignupFlowState copyWith({
    String? email,
    String? password,
    String? nickname,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    List<String>? allergies,
  }) {
    return SignupFlowState(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      allergies: allergies ?? this.allergies,
    );
  }
}

class SignupFlowNotifier extends StateNotifier<SignupFlowState> {
  SignupFlowNotifier() : super(SignupFlowState());

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }
  
  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }
  
  void setBirthDate(DateTime birthDate) {
    state = state.copyWith(birthDate: birthDate);
  }
  
  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }
  
  void setAllergies(List<String> allergies) {
    state = state.copyWith(allergies: allergies);
  }
  
  void setProfileInfo({
    String? nickname,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    List<String>? allergies,
  }) {
    state = state.copyWith(
      nickname: nickname,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
      gender: gender,
      allergies: allergies,
    );
  }

  void reset() {
    state = SignupFlowState();
  }
}

final signupFlowProvider =
    StateNotifierProvider<SignupFlowNotifier, SignupFlowState>((ref) {
  return SignupFlowNotifier();
});