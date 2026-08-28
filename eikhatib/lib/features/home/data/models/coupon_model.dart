class CouponModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discount;
  final bool isPercentage;
  final DateTime expiryDate;
  final bool isUsed;
  final String? brandLogo;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    required this.isPercentage,
    required this.expiryDate,
    this.isUsed = false,
    this.brandLogo,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isValid => !isExpired && !isUsed;
}
