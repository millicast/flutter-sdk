class TokenResponse {
  bool subscribeRequiresAuth;
  String wsUrl;
  String jwt;
  String streamAccountId;
  List<dynamic> urls;

  TokenResponse(
      {required this.jwt,
      required this.streamAccountId,
      required this.wsUrl,
      required this.urls,
      required this.subscribeRequiresAuth});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
        jwt: json['jwt'] as String,
        streamAccountId: json['streamAccountId'] as String,
        wsUrl: json['wsUrl'] as String,
        subscribeRequiresAuth: (json['subscribeRequiresAuth'] ?? false) as bool,
        urls: json['urls'] as List<dynamic>);
  }
}
