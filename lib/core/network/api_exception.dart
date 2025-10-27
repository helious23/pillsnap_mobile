/// API 관련 커스텀 예외 클래스들
///
/// 네트워크 요청 중 발생할 수 있는 다양한 에러 상황을
/// 명시적으로 구분하여 처리하기 위한 예외 클래스들입니다.
library;

/// API 예외의 기본 클래스
abstract class ApiException implements Exception {
  /// 사용자에게 표시할 에러 메시지
  final String message;

  /// 원본 에러 (선택적)
  final dynamic originalError;

  /// 스택 트레이스 (선택적)
  final StackTrace? stackTrace;

  const ApiException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return '$runtimeType: $message (원본: $originalError)';
    }
    return '$runtimeType: $message';
  }
}

/// 네트워크 연결 실패 예외
///
/// 인터넷 연결이 없거나 서버에 도달할 수 없을 때 발생
class NetworkException extends ApiException {
  const NetworkException({
    super.message = '네트워크 연결을 확인해주세요',
    super.originalError,
    super.stackTrace,
  });
}

/// 요청 타임아웃 예외
///
/// 서버 응답이 지정된 시간 내에 도착하지 않을 때 발생
class TimeoutException extends ApiException {
  /// 타임아웃 시간 (초)
  final int timeoutSeconds;

  const TimeoutException({
    this.timeoutSeconds = 30,
    super.message = '요청 시간이 초과되었습니다',
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return '$runtimeType: $message (${timeoutSeconds}초)';
  }
}

/// 서버 에러 예외 (5xx)
///
/// 서버 내부 오류로 요청을 처리할 수 없을 때 발생
class ServerException extends ApiException {
  /// HTTP 상태 코드
  final int statusCode;

  /// 서버 응답 본문 (선택적)
  final String? responseBody;

  const ServerException({
    required this.statusCode,
    this.responseBody,
    super.message = '서버에 일시적인 문제가 발생했습니다',
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return '$runtimeType: $message (HTTP $statusCode)';
  }
}

/// 클라이언트 에러 예외 (4xx)
///
/// 잘못된 요청이나 인증 실패 등 클라이언트 측 문제로 발생
class ClientException extends ApiException {
  /// HTTP 상태 코드
  final int statusCode;

  /// 서버 응답 본문 (선택적)
  final String? responseBody;

  const ClientException({
    required this.statusCode,
    this.responseBody,
    super.message = '요청을 처리할 수 없습니다',
    super.originalError,
    super.stackTrace,
  });

  /// 인증 실패 여부 (401, 403)
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// 요청 데이터 오류 여부 (400)
  bool get isBadRequest => statusCode == 400;

  /// 리소스 없음 여부 (404)
  bool get isNotFound => statusCode == 404;

  @override
  String toString() {
    return '$runtimeType: $message (HTTP $statusCode)';
  }
}

/// JSON 파싱 실패 예외
///
/// 서버 응답을 JSON으로 변환하는 과정에서 발생
class ParseException extends ApiException {
  /// 파싱하려던 원본 데이터
  final String? rawData;

  const ParseException({
    this.rawData,
    super.message = '응답 데이터 처리 중 오류가 발생했습니다',
    super.originalError,
    super.stackTrace,
  });
}

/// 알 수 없는 예외
///
/// 위의 특정 카테고리에 속하지 않는 예외
class UnknownException extends ApiException {
  const UnknownException({
    super.message = '알 수 없는 오류가 발생했습니다',
    super.originalError,
    super.stackTrace,
  });
}

/// HTTP 상태 코드로부터 적절한 예외 생성
ApiException exceptionFromStatusCode(
  int statusCode, {
  String? responseBody,
  String? customMessage,
}) {
  final message = customMessage ?? _getDefaultMessage(statusCode);

  if (statusCode >= 500) {
    return ServerException(
      statusCode: statusCode,
      responseBody: responseBody,
      message: message,
    );
  } else if (statusCode >= 400) {
    return ClientException(
      statusCode: statusCode,
      responseBody: responseBody,
      message: message,
    );
  } else {
    return UnknownException(message: message);
  }
}

/// 상태 코드별 기본 메시지 반환
String _getDefaultMessage(int statusCode) {
  switch (statusCode) {
    case 400:
      return '잘못된 요청입니다';
    case 401:
      return '인증이 필요합니다';
    case 403:
      return '접근 권한이 없습니다';
    case 404:
      return '요청한 정보를 찾을 수 없습니다';
    case 408:
      return '요청 시간이 초과되었습니다';
    case 429:
      return '너무 많은 요청을 보냈습니다. 잠시 후 다시 시도해주세요';
    case 500:
      return '서버 내부 오류가 발생했습니다';
    case 502:
      return '서버 게이트웨이 오류가 발생했습니다';
    case 503:
      return '서버를 일시적으로 사용할 수 없습니다';
    case 504:
      return '서버 응답 시간이 초과되었습니다';
    default:
      return '알 수 없는 오류가 발생했습니다 (HTTP $statusCode)';
  }
}
