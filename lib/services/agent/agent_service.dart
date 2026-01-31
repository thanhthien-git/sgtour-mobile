import 'package:sgtourcus/api/api_service.dart';
import 'package:sgtourcus/models/agent/agent_response.dart';
import 'package:sgtourcus/models/agent/heygen_session.dart';

class AgentService {
  static final ApiService api = ApiService();

  Future<HeyGenSession?> createHeyGenSession(String languageCode) async {
    try {
      print("AgentService: Creating session with languageCode: $languageCode");
      final response = await api.get('/agent/session?lang=$languageCode');

      final rawData = response.data;
      if (rawData is Map<String, dynamic>) {
        return HeyGenSession.fromJson(rawData);
      }
      return null;
    } catch (e) {
      print("AgentService Error (Session): $e");
      return null;
    }
  }

  Future<void> endHeyGenSession(String sessionId) async {
    try {
      await api.post('/agent/close', data: {'sessionId': sessionId});
    } catch (e) {
      print("AgentService Error (End Session): $e");
    }
  }

  Future<AgentResponse> askAgent(String question, String? sessionId) async {
    try {
      final data = {'question': question};
      if (sessionId != null) {
        data['sessionId'] = sessionId;
      }

      final response = await api.post('/agent/ask', data: {...data});

      final rawData = response.data;
      if (rawData is Map<String, dynamic>) {
        return AgentResponse.fromJson(rawData);
      }
      return AgentResponse(replyText: "Lỗi dữ liệu", languageCode: "vi-VN");
    } catch (e) {
      print("AgentService Error (Ask): $e");
      return AgentResponse(
        replyText: "Hệ thống đang bận.",
        languageCode: "vi-VN",
      );
    }
  }
}
