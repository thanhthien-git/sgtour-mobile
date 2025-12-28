class HeyGenSession {
  final String sessionId;
  final String url;
  final String livekitAgentToken;

  HeyGenSession({
    required this.sessionId,
    required this.url,
    required this.livekitAgentToken,
  });
  factory HeyGenSession.fromJson(Map<String, dynamic> json) {
    return HeyGenSession(
      sessionId: json['sessionId'] ?? '',
      url: json['url'] ?? '',
      livekitAgentToken: json['livekitAgentToken'] ?? '',
    );
  }
}
