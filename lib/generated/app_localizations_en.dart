// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PillSnap';

  @override
  String get loading_analyzing => 'Analyzing...';

  @override
  String get loading_identifyingMedicine => 'Identifying medicine';

  @override
  String get camera_captureGuide =>
      'Position the pill in\nthe center of crosshair';

  @override
  String get camera_singleMode => 'Single Capture';

  @override
  String get camera_multiMode => 'Multi Capture';

  @override
  String get home_welcome => 'Welcome!';

  @override
  String get home_recentCaptures => 'Recent Captures';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_signup => 'Sign Up';

  @override
  String get auth_emailPlaceholder => 'Enter your email';

  @override
  String get auth_passwordPlaceholder => 'Enter your password';

  @override
  String get common_next => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_cancel => 'Cancel';
}
