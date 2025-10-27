// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'PillSnap';

  @override
  String get loading_analyzing => '분석 중...';

  @override
  String get loading_identifyingMedicine => '의약품을 식별하고 있습니다';

  @override
  String get camera_captureGuide => '알약을 십자선 중앙에\n위치시켜 주세요';

  @override
  String get camera_singleMode => '단일 촬영';

  @override
  String get camera_multiMode => '다중 촬영';

  @override
  String get home_welcome => '안녕하세요!';

  @override
  String get home_recentCaptures => '최근 촬영';

  @override
  String get auth_login => '로그인';

  @override
  String get auth_signup => '회원가입';

  @override
  String get auth_emailPlaceholder => '이메일을 입력하세요';

  @override
  String get auth_passwordPlaceholder => '비밀번호를 입력하세요';

  @override
  String get common_next => '다음';

  @override
  String get common_skip => '건너뛰기';

  @override
  String get common_confirm => '확인';

  @override
  String get common_cancel => '취소';
}
