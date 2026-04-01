class ApiException implements Exception {
  final String message;
  final String? status;

  ApiException(this.message, {this.status});

  @override
  String toString() => message;
}
