class AgentResponse {
  final String replyText;
  final String languageCode;

  AgentResponse({required this.replyText, required this.languageCode});

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      replyText: json['reply_text'] as String? ?? "Xin lỗi, có lỗi xảy ra.",
      languageCode: json['language_code'] as String? ?? "vi-VN",
    );
  }
}
