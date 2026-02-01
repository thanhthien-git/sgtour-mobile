/// Model for a travel team-up notification (ghép đội du lịch)
class CommunityTeamUpModel {
  final String id;
  final String creatorId;
  final String creatorName;
  final String title;
  final String? description;
  final String? destination;
  final String? startDate;
  final int maxMembers;
  final int currentMembers;
  final String createdAt;
  final List<String> joinedUserIds;

  const CommunityTeamUpModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    this.description,
    this.destination,
    this.startDate,
    this.maxMembers = 10,
    this.currentMembers = 1,
    required this.createdAt,
    this.joinedUserIds = const [],
  });

  factory CommunityTeamUpModel.fromJson(Map<String, dynamic> json) {
    final joined = json['joinedUserIds'] as List<dynamic>?;
    return CommunityTeamUpModel(
      id: json['id']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? '',
      creatorName: json['creatorName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      destination: json['destination'] as String?,
      startDate: json['startDate'] as String?,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 10,
      currentMembers: (json['currentMembers'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] as String? ?? '',
      joinedUserIds: joined?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
