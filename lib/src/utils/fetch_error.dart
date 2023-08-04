class FetchException implements Exception {
  /// Specific exception to identify the status error code from an API request.
  ///
  /// [message] - Message from the response of the API request.
  /// [status] - Status code from the failed API request.

  String message;
  int status;

  FetchException(this.message, this.status);

  @override
  String toString() => 'FetchException: $message';
}