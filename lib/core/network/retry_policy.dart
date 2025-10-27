import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pillsnap/core/network/api_exception.dart';

/// 재시도 정책을 정의하는 클래스
///
/// 네트워크 요청 실패 시 자동으로 재시도하는 로직을 제공합니다.
class RetryPolicy {
  /// 최대 재시도 횟수 (기본: 3회)
  final int maxRetries;

  /// 초기 지연 시간 (기본: 1초)
  final Duration initialDelay;

  /// 최대 지연 시간 (기본: 30초)
  final Duration maxDelay;

  /// 지수 백오프 배수 (기본: 2.0)
  final double backoffMultiplier;

  /// Jitter 적용 여부 (랜덤 지연 추가, 기본: true)
  final bool useJitter;

  /// 재시도 전 호출될 콜백 (선택적)
  final void Function(int attemptNumber, Duration delay, dynamic error)? onRetry;

  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.useJitter = true,
    this.onRetry,
  });

  /// 기본 정책 (3회 재시도, 지수 백오프)
  static const RetryPolicy standard = RetryPolicy();

  /// 공격적 정책 (5회 재시도, 짧은 초기 지연)
  static const RetryPolicy aggressive = RetryPolicy(
    maxRetries: 5,
    initialDelay: Duration(milliseconds: 500),
  );

  /// 보수적 정책 (2회 재시도, 긴 초기 지연)
  static const RetryPolicy conservative = RetryPolicy(
    maxRetries: 2,
    initialDelay: Duration(seconds: 2),
  );

  /// 재시도 없음 (즉시 실패)
  static const RetryPolicy none = RetryPolicy(maxRetries: 0);

  /// 재시도가 필요한 에러인지 판단
  ///
  /// 네트워크 에러, 타임아웃, 서버 에러(5xx)는 재시도 가능
  /// 클라이언트 에러(4xx)는 재시도 불가 (요청이 잘못됨)
  bool shouldRetry(dynamic error) {
    // ApiException 타입별 판단
    if (error is NetworkException) {
      return true; // 네트워크 연결 실패 → 재시도
    } else if (error is TimeoutException) {
      return true; // 타임아웃 → 재시도
    } else if (error is ServerException) {
      return true; // 서버 에러 (5xx) → 재시도
    } else if (error is ClientException) {
      // 429 (Too Many Requests)만 재시도
      return error.statusCode == 429;
    } else if (error is ParseException) {
      return false; // 파싱 에러 → 재시도 불가
    }

    // dart:io 예외 판단
    if (error is SocketException) {
      return true; // 소켓 에러 → 재시도
    } else if (error is HttpException) {
      return true; // HTTP 에러 → 재시도
    } else if (error is HandshakeException) {
      return false; // SSL 핸드셰이크 실패 → 재시도 불가 (인증서 문제)
    }

    // 기타 에러는 재시도 안 함
    return false;
  }

  /// 재시도 로직을 적용하여 함수 실행
  ///
  /// [operation]: 실행할 비동기 함수
  /// [operationName]: 작업 이름 (로깅용, 선택적)
  ///
  /// Returns: 작업 결과
  /// Throws: 최대 재시도 후에도 실패하면 마지막 에러를 throw
  Future<T> execute<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    int attemptNumber = 0;
    dynamic lastError;

    while (attemptNumber <= maxRetries) {
      try {
        if (attemptNumber > 0) {
          debugPrint(
            'RetryPolicy: Retry attempt $attemptNumber/$maxRetries'
            '${operationName != null ? ' for $operationName' : ''}',
          );
        }

        // 작업 실행
        return await operation();
      } catch (error) {
        lastError = error;
        attemptNumber++;

        // 재시도 불가능한 에러인 경우 즉시 throw
        if (!shouldRetry(error)) {
          debugPrint(
            'RetryPolicy: Error is not retryable'
            '${operationName != null ? ' for $operationName' : ''}: $error',
          );
          rethrow;
        }

        // 최대 재시도 횟수 도달
        if (attemptNumber > maxRetries) {
          debugPrint(
            'RetryPolicy: Max retries ($maxRetries) exceeded'
            '${operationName != null ? ' for $operationName' : ''}',
          );
          rethrow;
        }

        // 재시도 전 대기
        final delay = _calculateDelay(attemptNumber);
        debugPrint(
          'RetryPolicy: Retrying in ${delay.inMilliseconds}ms'
          '${operationName != null ? ' for $operationName' : ''}'
          ' (attempt $attemptNumber/$maxRetries)',
        );

        // 콜백 호출
        onRetry?.call(attemptNumber, delay, error);

        // 대기
        await Future<void>.delayed(delay);
      }
    }

    // 이 지점에 도달하면 안 되지만, 안전을 위해 마지막 에러 throw
    final Object errorToThrow = lastError as Object? ?? Exception('Unknown error during retry');
    Error.throwWithStackTrace(errorToThrow, StackTrace.current);
  }

  /// 재시도 지연 시간 계산 (지수 백오프 + Jitter)
  Duration _calculateDelay(int attemptNumber) {
    // 지수 백오프: initialDelay * (backoffMultiplier ^ (attemptNumber - 1))
    final exponentialDelay = initialDelay.inMilliseconds *
        pow(backoffMultiplier, attemptNumber - 1);

    // 최대 지연 시간 제한
    var delayMs = min(exponentialDelay, maxDelay.inMilliseconds.toDouble());

    // Jitter 추가 (±25% 랜덤)
    if (useJitter) {
      final random = Random();
      final jitterFactor = 0.75 + (random.nextDouble() * 0.5); // 0.75 ~ 1.25
      delayMs *= jitterFactor;
    }

    return Duration(milliseconds: delayMs.round());
  }

  @override
  String toString() {
    return 'RetryPolicy(maxRetries: $maxRetries, '
        'initialDelay: ${initialDelay.inMilliseconds}ms, '
        'maxDelay: ${maxDelay.inMilliseconds}ms, '
        'backoffMultiplier: $backoffMultiplier, '
        'useJitter: $useJitter)';
  }
}

/// 재시도 정책을 적용하는 헬퍼 함수
///
/// [operation]: 실행할 비동기 함수
/// [policy]: 재시도 정책 (기본: RetryPolicy.standard)
/// [operationName]: 작업 이름 (로깅용, 선택적)
///
/// Returns: 작업 결과
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  RetryPolicy policy = RetryPolicy.standard,
  String? operationName,
}) async {
  return policy.execute(operation, operationName: operationName);
}

/// 재시도 가능한 Future 래퍼
///
/// 사용 예:
/// ```dart
/// final result = await RetryableFuture(
///   () => apiClient.fetchData(),
///   policy: RetryPolicy.aggressive,
/// ).execute();
/// ```
class RetryableFuture<T> {
  final Future<T> Function() operation;
  final RetryPolicy policy;
  final String? operationName;

  const RetryableFuture(
    this.operation, {
    this.policy = RetryPolicy.standard,
    this.operationName,
  });

  /// 작업 실행
  Future<T> execute() {
    return policy.execute(operation, operationName: operationName);
  }
}
