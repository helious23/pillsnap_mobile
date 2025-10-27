import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pillsnap/core/router/app_router.dart';
import 'package:pillsnap/theme/app_theme.dart';
import 'package:pillsnap/core/network/api_client.dart';
import 'package:pillsnap/core/services/supabase_service.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드 (가장 먼저!)
  await dotenv.load(fileName: '.env');

  // 한국어 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);

  // Supabase 초기화
  await SupabaseService.initialize();

  // API 클라이언트 초기화
  await PillSnapAPIClient().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// 딥링크 처리 (app_links 패키지 사용)
  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();

    // 앱이 종료 상태에서 링크로 시작된 경우
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await SupabaseService.instance.handleDeepLink(initialUri);
      }
    } catch (e) {
      // 초기 링크 처리 실패는 무시
      debugPrint('Initial deep link failed: $e');
    }

    // 앱이 실행 중일 때 링크 처리
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) async {
        await SupabaseService.instance.handleDeepLink(uri);
      },
      onError: (Object err) {
        // 스트림 에러 처리
        debugPrint('Deep link stream error: $err');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PillSnap',
      theme: AppTheme.light(),
      routerConfig: router,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
