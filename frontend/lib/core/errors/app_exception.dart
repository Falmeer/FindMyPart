class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expired. Please login again.', statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException(super.message, this.errors, {super.statusCode = 422});
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error. Please try again.'])
      : super(message, statusCode: 500);
}
