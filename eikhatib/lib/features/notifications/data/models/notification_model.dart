class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['body'] ?? '',
      imageUrl: json['image_url'],
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isRead: json['is_read'] == 1,
    );
  }
}
