class UpvoteModel {
  final String id;
  final String resourceId;
  final String userId;
  final DateTime createdAt;

  const UpvoteModel({
    required this.id,
    required this.resourceId,
    required this.userId,
    required this.createdAt,
  });

  factory UpvoteModel.fromMap(Map<String, dynamic> map) {
    return UpvoteModel(
      id: map['id'],
      resourceId: map['resource_id'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resource_id': resourceId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
