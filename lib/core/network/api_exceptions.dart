class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.responseBody});

  final String message;
  final int? statusCode;
  final String? responseBody;

  @override
  String toString() => message;
}

class AuthExpiredException extends ApiException {
  const AuthExpiredException(
    super.message, {
    super.statusCode,
    super.responseBody,
  });
}
