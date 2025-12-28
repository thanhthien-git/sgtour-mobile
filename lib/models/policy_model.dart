/// Policy and terms model
class PolicyModel {
  final String title;
  final String content;
  final String languageCode;

  PolicyModel({
    required this.title,
    required this.content,
    required this.languageCode,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      title: json['title'] ?? 'Policy',
      content: json['content'] ?? '',
      languageCode: json['languageCode'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'languageCode': languageCode};
  }
}
