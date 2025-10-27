import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// 앱 제목
  ///
  /// In ko, this message translates to:
  /// **'PillSnap'**
  String get appTitle;

  /// 로딩 화면 - 분석 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'분석 중...'**
  String get loading_analyzing;

  /// 로딩 화면 - 약품 식별 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'의약품을 식별하고 있습니다'**
  String get loading_identifyingMedicine;

  /// 카메라 화면 - 촬영 가이드
  ///
  /// In ko, this message translates to:
  /// **'알약을 십자선 중앙에\n위치시켜 주세요'**
  String get camera_captureGuide;

  /// 카메라 모드 - 단일
  ///
  /// In ko, this message translates to:
  /// **'단일 촬영'**
  String get camera_singleMode;

  /// 카메라 모드 - 다중
  ///
  /// In ko, this message translates to:
  /// **'다중 촬영'**
  String get camera_multiMode;

  /// 홈 화면 - 환영 메시지
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요!'**
  String get home_welcome;

  /// 홈 화면 - 최근 촬영 섹션
  ///
  /// In ko, this message translates to:
  /// **'최근 촬영'**
  String get home_recentCaptures;

  /// 인증 - 로그인
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get auth_login;

  /// 인증 - 회원가입
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get auth_signup;

  /// 이메일 입력 필드 플레이스홀더
  ///
  /// In ko, this message translates to:
  /// **'이메일을 입력하세요'**
  String get auth_emailPlaceholder;

  /// 비밀번호 입력 필드 플레이스홀더
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력하세요'**
  String get auth_passwordPlaceholder;

  /// 공통 - 다음 버튼
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get common_next;

  /// 공통 - 건너뛰기 버튼
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get common_skip;

  /// 공통 - 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get common_confirm;

  /// 공통 - 취소 버튼
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get common_cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
