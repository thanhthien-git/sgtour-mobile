class AiChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const AiChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
