import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 온보딩 완료 상태를 관리하는 프로바이더
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final status = prefs.getBool('onboarding_completed') ?? false;
  debugPrint('🔍 [ONBOARDING_PROVIDER] 온보딩 상태 조회: $status');
  return status;
});

/// 온보딩 상태 컨트롤러
class OnboardingController extends Notifier<void> {
  @override
  void build() {}

  /// 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  /// 온보딩 상태 리셋 (테스트용)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
  }
}

/// 온보딩 컨트롤러 프로바이더
final onboardingControllerProvider = 
    NotifierProvider<OnboardingController, void>(OnboardingController.new);