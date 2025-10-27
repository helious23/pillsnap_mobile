import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/profile.dart';

/// 인증 리포지토리 프로바이더
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// 프로필 리포지토리 프로바이더
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// 인증 상태 프로바이더
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// 현재 사용자 프로바이더
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
    data: (state) => state.session?.user,
  );
});

/// 로그인 여부 프로바이더
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// 프로필 완성 여부 프로바이더
final profileCompletedProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  debugPrint('🔍 [PROFILE_PROVIDER] 프로필 완료 체크 시작 - User: ${user?.id}');
  
  if (user == null) {
    debugPrint('🔍 [PROFILE_PROVIDER] User null - false 반환');
    return false;
  }
  
  try {
    final profileRepo = ref.watch(profileRepositoryProvider);
    final profile = await profileRepo.fetchMyProfile();
    
    if (profile == null) {
      debugPrint('🔍 [PROFILE_PROVIDER] Profile null - false 반환');
      return false;
    }
    
    debugPrint('🔍 [PROFILE_PROVIDER] 프로필 데이터:');
    debugPrint('  - user_id: ${profile.id}');
    debugPrint('  - profileCompleted: ${profile.profileCompleted}');
    debugPrint('  - displayName: ${profile.displayName}');
    debugPrint('  - phone: ${profile.phone}');
    
    // profile_completed 플래그만 확인 (레거시 체크 제거)
    // 새 사용자는 이 플래그가 false이므로 프로필 설정 페이지로 이동함
    final result = profile.profileCompleted;
    debugPrint('🔍 [PROFILE_PROVIDER] 최종 결과: $result');
    return result;
  } catch (e) {
    debugPrint('❌ [PROFILE_PROVIDER] 프로필 완성 여부 체크 실패: $e');
    return false;
  }
});

/// 현재 사용자 프로필 프로바이더
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  try {
    final profileRepo = ref.watch(profileRepositoryProvider);
    return await profileRepo.fetchMyProfile();
  } catch (e) {
    return null;
  }
});

/// 인증 컨트롤러 (로그인/회원가입 등 액션)
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final ProfileRepository _profileRepository;
  
  AuthController(this._repository, this._profileRepository) : super(const AsyncValue.data(null));
  
  /// 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    List<String>? allergies,
  }) async {
    debugPrint('🔍 [AUTH_CTRL.signUp] 시작 - email: $email');
    state = const AsyncValue.loading();
    
    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      debugPrint('🔍 [AUTH_CTRL.signUp] 응답 수신 - User: ${response.user?.id}');
      
      if (response.user != null) {
        // 프로필 추가 정보 업데이트
        if (phoneNumber != null || birthDate != null || gender != null || allergies != null) {
          debugPrint('🔍 [AUTH_CTRL.signUp] 프로필 추가 정보 업데이트 시도');
          try {
            await _profileRepository.updateProfile(
              phoneNumber: phoneNumber,
              birthDate: birthDate,
              gender: gender,
              allergies: allergies,
            );
            debugPrint('✅ [AUTH_CTRL.signUp] 프로필 업데이트 성공');
          } catch (e) {
            debugPrint('⚠️ [AUTH_CTRL.signUp] 프로필 업데이트 실패 (무시): $e');
          }
        }
        
        state = const AsyncValue.data(null);
        debugPrint('✅ [AUTH_CTRL.signUp] 회원가입 완료');
      } else {
        debugPrint('🚨 [AUTH_CTRL.signUp] User null - 회원가입 실패');
        state = AsyncValue.error(
          Exception('회원가입에 실패했습니다'),
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      debugPrint('🚨 [AUTH_CTRL.signUp] 에러 캐치: $e');
      state = AsyncValue.error(e, stack);
      rethrow; // 에러를 다시 throw하여 UI에서 catch할 수 있도록
    }
  }
  
  /// 로그인
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _repository.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session != null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          Exception('로그인에 실패했습니다'),
          StackTrace.current,
        );
        throw Exception('로그인에 실패했습니다');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;  // 에러를 다시 throw하여 호출자에게 전파
    }
  }
  
  /// 비밀번호 재설정 요청
  Future<void> requestPasswordReset(String email) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// 이메일 인증 재전송
  Future<void> resendVerificationEmail(String email) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.resendVerificationEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// 인증 컨트롤러 프로바이더
final authControllerProvider = 
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  return AuthController(repository, profileRepository);
});