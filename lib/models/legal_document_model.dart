enum LegalDocumentType {
  privacyPolicy('privacy_policy'),
  termsOfService('terms_of_service');

  final String value;
  const LegalDocumentType(this.value);

  static LegalDocumentType fromString(String value) {
    return LegalDocumentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LegalDocumentType.privacyPolicy,
    );
  }
}

class LegalDocumentModel {
  final LegalDocumentType type;
  final String content;
  final String languageCode;

  const LegalDocumentModel({
    required this.type,
    required this.content,
    required this.languageCode,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      type: LegalDocumentType.fromString(json['type'] as String? ?? ''),
      content: json['content'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'content': content,
      'languageCode': languageCode,
    };
  }
}
