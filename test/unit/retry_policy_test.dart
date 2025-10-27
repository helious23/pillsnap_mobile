import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillsnap/core/network/api_exception.dart';
import 'package:pillsnap/core/network/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    group('shouldRetry', () {
      const policy = RetryPolicy.standard;

      test('NetworkException은 재시도 가능', () {
        const error = NetworkException();
        expect(policy.shouldRetry(error), isTrue);
      });

      test('TimeoutException은 재시도 가능', () {
        const error = TimeoutException();
        expect(policy.shouldRetry(error), isTrue);
      });

      test('ServerException(5xx)은 재시도 가능', () {
        const error = ServerException(statusCode: 500);
        expect(policy.shouldRetry(error), isTrue);
      });

      test('ClientException은 기본적으로 재시도 불가', () {
        const error = ClientException(statusCode: 400);
        expect(policy.shouldRetry(error), isFalse);
      });

      test('ClientException(429 Too Many Requests)은 재시도 가능', () {
        const error = ClientException(statusCode: 429);
        expect(policy.shouldRetry(error), isTrue);
      });

      test('ParseException은 재시도 불가', () {
        const error = ParseException();
        expect(policy.shouldRetry(error), isFalse);
      });

      test('SocketException은 재시도 가능', () {
        final error = const SocketException('Connection refused');
        expect(policy.shouldRetry(error), isTrue);
      });

      test('HttpException은 재시도 가능', () {
        final error = const HttpException('Bad response');
        expect(policy.shouldRetry(error), isTrue);
      });

      test('HandshakeException은 재시도 불가 (SSL 문제)', () {
        final error = HandshakeException('SSL handshake failed');
        expect(policy.shouldRetry(error), isFalse);
      });

      test('일반 Exception은 재시도 불가', () {
        final error = Exception('Unknown error');
        expect(policy.shouldRetry(error), isFalse);
      });
    });

    group('execute', () {
      test('성공하는 작업은 재시도 없이 즉시 반환', () async {
        const policy = RetryPolicy.standard;
        int attemptCount = 0;

        final result = await policy.execute(() async {
          attemptCount++;
          return 'success';
        });

        expect(result, 'success');
        expect(attemptCount, 1);
      });

      test('재시도 불가능한 에러는 즉시 throw', () async {
        const policy = RetryPolicy.standard;
        int attemptCount = 0;

        expect(
          () => policy.execute(() async {
            attemptCount++;
            throw const ClientException(statusCode: 400);
          }),
          throwsA(isA<ClientException>()),
        );

        // 재시도 하지 않으므로 1회만 실행
        expect(attemptCount, 1);
      });

      test('재시도 가능한 에러는 maxRetries까지 재시도', () async {
        const policy = RetryPolicy(
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 10),
          useJitter: false,
        );
        int attemptCount = 0;

        await expectLater(
          policy.execute(() async {
            attemptCount++;
            throw const NetworkException();
          }),
          throwsA(isA<NetworkException>()),
        );

        // 초기 시도(1회) + 재시도(3회) = 총 4회
        expect(attemptCount, 4);
      });

      test('중간에 성공하면 재시도 중단', () async {
        const policy = RetryPolicy(
          maxRetries: 5,
          initialDelay: Duration(milliseconds: 10),
        );
        int attemptCount = 0;

        final result = await policy.execute(() async {
          attemptCount++;
          if (attemptCount < 3) {
            throw const NetworkException();
          }
          return 'recovered';
        });

        expect(result, 'recovered');
        expect(attemptCount, 3); // 3번째 시도에서 성공
      });

      test('onRetry 콜백이 호출됨', () async {
        final retryLog = <int>[];
        final policy = RetryPolicy(
          maxRetries: 2,
          initialDelay: Duration(milliseconds: 10),
          useJitter: false,
          onRetry: (attemptNumber, delay, error) {
            retryLog.add(attemptNumber);
          },
        );

        try {
          await policy.execute(() async {
            throw const NetworkException();
          });
        } catch (_) {
          // 예외 무시
        }

        expect(retryLog, [1, 2]); // 1차, 2차 재시도 시 콜백 호출
      });

      test('지수 백오프 지연 시간이 증가함', () async {
        final delays = <Duration>[];
        final policy = RetryPolicy(
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 100),
          backoffMultiplier: 2.0,
          useJitter: false,
          onRetry: (attemptNumber, delay, error) {
            delays.add(delay);
          },
        );

        try {
          await policy.execute(() async {
            throw const NetworkException();
          });
        } catch (_) {
          // 예외 무시
        }

        // 100ms, 200ms, 400ms (지수 백오프)
        expect(delays[0].inMilliseconds, 100);
        expect(delays[1].inMilliseconds, 200);
        expect(delays[2].inMilliseconds, 400);
      });

      test('maxDelay를 초과하지 않음', () async {
        final delays = <Duration>[];
        final policy = RetryPolicy(
          maxRetries: 5,
          initialDelay: Duration(milliseconds: 100),
          maxDelay: Duration(milliseconds: 300),
          backoffMultiplier: 2.0,
          useJitter: false,
          onRetry: (attemptNumber, delay, error) {
            delays.add(delay);
          },
        );

        try {
          await policy.execute(() async {
            throw const NetworkException();
          });
        } catch (_) {
          // 예외 무시
        }

        // 100ms, 200ms, 300ms(max), 300ms(max), 300ms(max)
        expect(delays[0].inMilliseconds, 100);
        expect(delays[1].inMilliseconds, 200);
        expect(delays[2].inMilliseconds, 300);
        expect(delays[3].inMilliseconds, 300);
        expect(delays[4].inMilliseconds, 300);
      });
    });

    group('정책 프리셋', () {
      test('standard 정책 - 3회 재시도, 1초 초기 지연', () {
        expect(RetryPolicy.standard.maxRetries, 3);
        expect(RetryPolicy.standard.initialDelay, Duration(seconds: 1));
      });

      test('aggressive 정책 - 5회 재시도, 500ms 초기 지연', () {
        expect(RetryPolicy.aggressive.maxRetries, 5);
        expect(RetryPolicy.aggressive.initialDelay, Duration(milliseconds: 500));
      });

      test('conservative 정책 - 2회 재시도, 2초 초기 지연', () {
        expect(RetryPolicy.conservative.maxRetries, 2);
        expect(RetryPolicy.conservative.initialDelay, Duration(seconds: 2));
      });

      test('none 정책 - 0회 재시도 (즉시 실패)', () {
        expect(RetryPolicy.none.maxRetries, 0);
      });
    });

    group('withRetry 헬퍼 함수', () {
      test('기본 정책으로 작업 실행', () async {
        int attemptCount = 0;

        final result = await withRetry(() async {
          attemptCount++;
          return 'success';
        });

        expect(result, 'success');
        expect(attemptCount, 1);
      });

      test('커스텀 정책 적용 가능', () async {
        int attemptCount = 0;

        try {
          await withRetry(
            () async {
              attemptCount++;
              throw const NetworkException();
            },
            policy: RetryPolicy.aggressive,
          );
        } catch (_) {
          // 예외 무시
        }

        // aggressive: 초기(1) + 재시도(5) = 6회
        expect(attemptCount, 6);
      });
    });

    group('RetryableFuture', () {
      test('작업 래핑 및 실행', () async {
        int attemptCount = 0;

        final retryable = RetryableFuture(
          () async {
            attemptCount++;
            return 'wrapped';
          },
          policy: RetryPolicy.standard,
        );

        final result = await retryable.execute();

        expect(result, 'wrapped');
        expect(attemptCount, 1);
      });
    });

    group('toString', () {
      test('정책 정보를 문자열로 출력', () {
        const policy = RetryPolicy(
          maxRetries: 3,
          initialDelay: Duration(seconds: 1),
          maxDelay: Duration(seconds: 30),
          backoffMultiplier: 2.0,
          useJitter: true,
        );

        final str = policy.toString();

        expect(str, contains('maxRetries: 3'));
        expect(str, contains('initialDelay: 1000ms'));
        expect(str, contains('maxDelay: 30000ms'));
        expect(str, contains('backoffMultiplier: 2.0'));
        expect(str, contains('useJitter: true'));
      });
    });
  });
}
