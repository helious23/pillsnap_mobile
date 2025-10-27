import 'package:flutter_test/flutter_test.dart';
import 'package:pillsnap/core/network/api_exception.dart';

void main() {
  group('ApiException', () {
    group('NetworkException', () {
      test('기본 메시지로 생성 가능', () {
        const exception = NetworkException();

        expect(exception.message, '네트워크 연결을 확인해주세요');
        expect(exception.originalError, isNull);
        expect(exception.stackTrace, isNull);
      });

      test('커스텀 메시지로 생성 가능', () {
        const exception = NetworkException(message: '커스텀 에러');

        expect(exception.message, '커스텀 에러');
      });

      test('원본 에러와 스택 트레이스 저장 가능', () {
        final originalError = Exception('원본');
        final stackTrace = StackTrace.current;

        final exception = NetworkException(
          message: '테스트',
          originalError: originalError,
          stackTrace: stackTrace,
        );

        expect(exception.originalError, originalError);
        expect(exception.stackTrace, stackTrace);
      });

      test('toString()이 올바른 형식 반환', () {
        const exception = NetworkException(message: '연결 실패');

        expect(exception.toString(), contains('NetworkException'));
        expect(exception.toString(), contains('연결 실패'));
      });
    });

    group('TimeoutException', () {
      test('기본 타임아웃 시간 30초', () {
        const exception = TimeoutException();

        expect(exception.timeoutSeconds, 30);
        expect(exception.message, '요청 시간이 초과되었습니다');
      });

      test('커스텀 타임아웃 시간 설정 가능', () {
        const exception = TimeoutException(timeoutSeconds: 60);

        expect(exception.timeoutSeconds, 60);
      });

      test('toString()에 타임아웃 시간 포함', () {
        const exception = TimeoutException(timeoutSeconds: 45);

        expect(exception.toString(), contains('45초'));
      });
    });

    group('ServerException', () {
      test('상태 코드와 메시지 저장', () {
        const exception = ServerException(
          statusCode: 500,
          message: '서버 에러',
        );

        expect(exception.statusCode, 500);
        expect(exception.message, '서버 에러');
      });

      test('응답 본문 저장 가능', () {
        const exception = ServerException(
          statusCode: 503,
          responseBody: '{"error": "Service Unavailable"}',
        );

        expect(exception.responseBody, '{"error": "Service Unavailable"}');
      });

      test('toString()에 HTTP 상태 코드 포함', () {
        const exception = ServerException(statusCode: 502);

        expect(exception.toString(), contains('HTTP 502'));
      });
    });

    group('ClientException', () {
      test('상태 코드와 메시지 저장', () {
        const exception = ClientException(
          statusCode: 400,
          message: '잘못된 요청',
        );

        expect(exception.statusCode, 400);
        expect(exception.message, '잘못된 요청');
      });

      test('isAuthError - 401 인증 에러 확인', () {
        const exception401 = ClientException(statusCode: 401);
        const exception403 = ClientException(statusCode: 403);
        const exception400 = ClientException(statusCode: 400);

        expect(exception401.isAuthError, isTrue);
        expect(exception403.isAuthError, isTrue);
        expect(exception400.isAuthError, isFalse);
      });

      test('isBadRequest - 400 에러 확인', () {
        const exception400 = ClientException(statusCode: 400);
        const exception404 = ClientException(statusCode: 404);

        expect(exception400.isBadRequest, isTrue);
        expect(exception404.isBadRequest, isFalse);
      });

      test('isNotFound - 404 에러 확인', () {
        const exception404 = ClientException(statusCode: 404);
        const exception400 = ClientException(statusCode: 400);

        expect(exception404.isNotFound, isTrue);
        expect(exception400.isNotFound, isFalse);
      });
    });

    group('ParseException', () {
      test('원본 데이터 저장 가능', () {
        const exception = ParseException(
          rawData: '{"invalid json',
          message: '파싱 실패',
        );

        expect(exception.rawData, '{"invalid json');
        expect(exception.message, '파싱 실패');
      });

      test('기본 메시지 사용 가능', () {
        const exception = ParseException();

        expect(exception.message, '응답 데이터 처리 중 오류가 발생했습니다');
      });
    });

    group('UnknownException', () {
      test('기본 메시지로 생성', () {
        const exception = UnknownException();

        expect(exception.message, '알 수 없는 오류가 발생했습니다');
      });

      test('커스텀 메시지로 생성', () {
        const exception = UnknownException(message: '예상치 못한 오류');

        expect(exception.message, '예상치 못한 오류');
      });
    });

    group('exceptionFromStatusCode', () {
      test('5xx 상태 코드는 ServerException 반환', () {
        final exception500 = exceptionFromStatusCode(500);
        final exception503 = exceptionFromStatusCode(503);

        expect(exception500, isA<ServerException>());
        expect(exception503, isA<ServerException>());
        expect((exception500 as ServerException).statusCode, 500);
      });

      test('4xx 상태 코드는 ClientException 반환', () {
        final exception400 = exceptionFromStatusCode(400);
        final exception404 = exceptionFromStatusCode(404);

        expect(exception400, isA<ClientException>());
        expect(exception404, isA<ClientException>());
        expect((exception400 as ClientException).statusCode, 400);
      });

      test('커스텀 메시지 적용 가능', () {
        final exception = exceptionFromStatusCode(
          404,
          customMessage: '리소스를 찾을 수 없음',
        );

        expect(exception.message, '리소스를 찾을 수 없음');
      });

      test('상태 코드별 기본 메시지 확인', () {
        expect(exceptionFromStatusCode(400).message, '잘못된 요청입니다');
        expect(exceptionFromStatusCode(401).message, '인증이 필요합니다');
        expect(exceptionFromStatusCode(403).message, '접근 권한이 없습니다');
        expect(exceptionFromStatusCode(404).message, '요청한 정보를 찾을 수 없습니다');
        expect(exceptionFromStatusCode(429).message, contains('너무 많은 요청'));
        expect(exceptionFromStatusCode(500).message, '서버 내부 오류가 발생했습니다');
        expect(exceptionFromStatusCode(503).message, '서버를 일시적으로 사용할 수 없습니다');
      });

      test('응답 본문 포함 가능', () {
        final exception = exceptionFromStatusCode(
          500,
          responseBody: '{"error": "Internal Server Error"}',
        );

        expect((exception as ServerException).responseBody, '{"error": "Internal Server Error"}');
      });
    });
  });
}
