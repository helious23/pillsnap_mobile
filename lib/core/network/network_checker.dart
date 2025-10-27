import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 네트워크 연결 상태를 확인하는 유틸리티 클래스
///
/// 디바이스의 네트워크 연결 상태와 실제 인터넷 접근 가능 여부를 확인합니다.
class NetworkChecker {
  final Connectivity _connectivity = Connectivity();

  /// 싱글톤 인스턴스
  static final NetworkChecker _instance = NetworkChecker._internal();
  factory NetworkChecker() => _instance;
  NetworkChecker._internal();

  /// 연결 상태 스트림 구독
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// 연결 상태 변경 콜백
  void Function(bool isConnected)? _onConnectionChanged;

  /// 현재 연결 상태 확인 (빠른 체크)
  ///
  /// Returns: WiFi, Mobile, Ethernet 등 연결되어 있으면 true
  /// 실제 인터넷 접근 가능 여부는 확인하지 않음
  Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _isConnected(result);
    } catch (e) {
      debugPrint('NetworkChecker: Connection check failed - $e');
      return false;
    }
  }

  /// 실제 인터넷 접근 가능 여부 확인 (느린 체크)
  ///
  /// [host]: 테스트할 호스트 (기본: google.com)
  /// [timeout]: 타임아웃 시간 (기본: 10초)
  ///
  /// Returns: 실제 인터넷 접근이 가능하면 true
  Future<bool> hasInternetAccess({
    String host = 'google.com',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // 먼저 빠른 체크
      final hasConn = await hasConnection();
      if (!hasConn) {
        return false;
      }

      // 실제 인터넷 접근 테스트
      final result = await InternetAddress.lookup(host).timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('NetworkChecker: Internet access check failed - Socket error: $e');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('NetworkChecker: Internet access check failed - Timeout: $e');
      return false;
    } catch (e) {
      debugPrint('NetworkChecker: Internet access check failed - $e');
      return false;
    }
  }

  /// 연결 타입 확인
  ///
  /// Returns: 'wifi', 'mobile', 'ethernet', 'none' 등
  Future<String> getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.wifi)) {
        return 'wifi';
      } else if (result.contains(ConnectivityResult.mobile)) {
        return 'mobile';
      } else if (result.contains(ConnectivityResult.ethernet)) {
        return 'ethernet';
      } else if (result.contains(ConnectivityResult.vpn)) {
        return 'vpn';
      } else {
        return 'none';
      }
    } catch (e) {
      debugPrint('NetworkChecker: Get connection type failed - $e');
      return 'unknown';
    }
  }

  /// 연결 상태 변경 감지 시작
  ///
  /// [onConnectionChanged]: 연결 상태 변경 시 호출될 콜백
  void startMonitoring({required void Function(bool isConnected) onConnectionChanged}) {
    _onConnectionChanged = onConnectionChanged;

    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = _isConnected(results);
        debugPrint('NetworkChecker: Connection changed - $isConnected (${results.map((r) => r.name).join(', ')})');
        _onConnectionChanged?.call(isConnected);
      },
      onError: (Object error) {
        debugPrint('NetworkChecker: Monitoring error - $error');
        _onConnectionChanged?.call(false);
      },
    );

    debugPrint('NetworkChecker: Monitoring started');
  }

  /// 연결 상태 변경 감지 중지
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    _onConnectionChanged = null;
    debugPrint('NetworkChecker: Monitoring stopped');
  }

  /// ConnectivityResult 리스트가 연결 상태인지 확인
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);
  }

  /// 리소스 정리
  void dispose() {
    stopMonitoring();
  }
}

/// 네트워크 상태를 나타내는 열거형
enum NetworkStatus {
  /// 네트워크 연결됨 + 인터넷 접근 가능
  connected,

  /// 네트워크 연결됨 but 인터넷 접근 불가 (캡티브 포털 등)
  disconnected,

  /// 네트워크 연결 안 됨
  offline,
}

/// 네트워크 상태를 확인하는 헬퍼 함수
///
/// [quickCheck]: true면 빠른 체크만 수행 (기본: false)
Future<NetworkStatus> checkNetworkStatus({bool quickCheck = false}) async {
  final checker = NetworkChecker();

  final hasConnection = await checker.hasConnection();

  if (!hasConnection) {
    return NetworkStatus.offline;
  }

  if (quickCheck) {
    return NetworkStatus.connected;
  }

  final hasInternet = await checker.hasInternetAccess();

  return hasInternet ? NetworkStatus.connected : NetworkStatus.disconnected;
}
