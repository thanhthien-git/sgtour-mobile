import 'package:sgtour_mobile/api/api_service.dart';

class AgentService {
  final ApiService api;

  AgentService(this.api);

  Future<AgentResponse> askAgent(String question) async {
    try {
      final response = await api.post(
        '/agent/ask',
        data: {'question': question},
      );

      final rawData = response.data;

      if (rawData is Map<String, dynamic>) {
        return AgentResponse.fromJson(rawData);
      } else {
        return AgentResponse(
          replyText: "Lỗi định dạng dữ liệu",
          languageCode: "vi-VN",
        );
      }
    } catch (e) {
      return AgentResponse(
        replyText: "Hệ thống đang bận, vui lòng thử lại sau.",
        languageCode: "vi-VN",
      );
    }
  }
}

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
