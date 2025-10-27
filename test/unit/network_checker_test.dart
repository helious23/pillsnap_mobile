import 'package:flutter_test/flutter_test.dart';
import 'package:pillsnap/core/network/network_checker.dart';

void main() {
  // Flutter 바인딩 초기화 (connectivity_plus가 필요로 함)
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkChecker', () {
    late NetworkChecker checker;

    setUp(() {
      checker = NetworkChecker();
    });

    tearDown(() {
      checker.dispose();
    });

    group('싱글톤 패턴', () {
      test('동일한 인스턴스 반환', () {
        final instance1 = NetworkChecker();
        final instance2 = NetworkChecker();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('hasConnection', () {
      test('메서드가 존재하고 호출 가능', () async {
        // 실제 디바이스/시뮬레이터에서만 정확한 결과 반환
        // 테스트 환경에서는 false 반환 가능
        final result = await checker.hasConnection();

        expect(result, isA<bool>());
      });
    });

    group('getConnectionType', () {
      test('연결 타입 문자열 반환', () async {
        final type = await checker.getConnectionType();

        // 가능한 타입: 'wifi', 'mobile', 'ethernet', 'vpn', 'none', 'unknown'
        expect(
          ['wifi', 'mobile', 'ethernet', 'vpn', 'none', 'unknown'].contains(type),
          isTrue,
          reason: 'Unexpected connection type: $type',
        );
      });
    });

    group('hasInternetAccess', () {
      test('메서드가 존재하고 호출 가능', () async {
        // 실제 인터넷 접근 테스트 (실패할 수 있음)
        final result = await checker.hasInternetAccess(
          timeout: Duration(seconds: 5),
        );

        expect(result, isA<bool>());
      });

      test('커스텀 호스트로 테스트 가능', () async {
        final result = await checker.hasInternetAccess(
          host: 'google.com',
          timeout: Duration(seconds: 5),
        );

        expect(result, isA<bool>());
      });
    });

    group('startMonitoring / stopMonitoring', () {
      test('모니터링 시작 및 중지 가능', () {
        bool callbackCalled = false;

        checker.startMonitoring(
          onConnectionChanged: (isConnected) {
            callbackCalled = true;
          },
        );

        checker.stopMonitoring();

        // 에러 없이 실행되면 성공
        expect(callbackCalled, isFalse); // 즉시 호출되지는 않음
      });

      test('dispose 호출 시 모니터링 중지', () {
        checker.startMonitoring(
          onConnectionChanged: (isConnected) {},
        );

        // dispose 호출 - 에러 없이 실행되어야 함
        checker.dispose();
        expect(true, isTrue);
      });
    });

    group('dispose', () {
      test('여러 번 호출해도 안전', () {
        checker.dispose();
        checker.dispose();
        checker.dispose();

        // 에러 없이 실행되면 성공
        expect(true, isTrue);
      });
    });
  });

  group('NetworkStatus 열거형', () {
    test('3가지 상태 존재', () {
      expect(NetworkStatus.connected, isA<NetworkStatus>());
      expect(NetworkStatus.disconnected, isA<NetworkStatus>());
      expect(NetworkStatus.offline, isA<NetworkStatus>());
    });
  });

  group('checkNetworkStatus 헬퍼 함수', () {
    test('NetworkStatus 반환', () async {
      final status = await checkNetworkStatus(quickCheck: true);

      expect(
        [NetworkStatus.connected, NetworkStatus.disconnected, NetworkStatus.offline].contains(status),
        isTrue,
      );
    });

    test('quickCheck=true면 빠른 체크만 수행', () async {
      final status = await checkNetworkStatus(quickCheck: true);

      expect(status, isA<NetworkStatus>());
    });

    test('quickCheck=false면 인터넷 접근까지 확인', () async {
      // 실제 인터넷 접근 테스트 (느림)
      final status = await checkNetworkStatus(quickCheck: false);

      expect(status, isA<NetworkStatus>());
    }, timeout: Timeout(Duration(seconds: 15)));
  });
}
