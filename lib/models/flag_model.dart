class FlagModel {
  final String id;
  final String resourceId;
  final String userId;
  final String reason; // Closed, Wrong Info, Spam
  final DateTime createdAt;

  const FlagModel({
    required this.id,
    required this.resourceId,
    required this.userId,
    required this.reason,
    required this.createdAt,
  });

  factory FlagModel.fromMap(Map<String, dynamic> map) {
    return FlagModel(
      id: map['id'],
      resourceId: map['resource_id'],
      userId: map['user_id'],
      reason: map['reason'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resource_id': resourceId,
      'user_id': userId,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
