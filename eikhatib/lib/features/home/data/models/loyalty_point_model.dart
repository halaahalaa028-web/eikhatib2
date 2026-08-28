class LoyaltyPointModel {
  final String id;
  final String title;
  final String description;
  final int points;
  final DateTime date;
  final bool isEarned; // true if earned, false if spent/redeemed

  final String? imageUrl;

  LoyaltyPointModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.date,
    this.isEarned = true,
    this.imageUrl,
  });
}
