class FetchException implements Exception {
  String message;
  int status;

  FetchException(this.message, this.status);

  @override
  String toString() => 'FetchException: $message';
}