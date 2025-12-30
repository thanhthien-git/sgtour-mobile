class AiChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool? isGreeting;

  const AiChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isGreeting,
  });
}
