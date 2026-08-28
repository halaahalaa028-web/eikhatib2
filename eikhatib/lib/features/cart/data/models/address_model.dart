class AddressModel {
  final String id;
  final String title;
  final String street;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  // Customer info
  final String? firstName;
  final String? lastName;
  final String? storeName;
  final String? phoneNumber;

  AddressModel({
    required this.id,
    required this.title,
    required this.street,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.firstName,
    this.lastName,
    this.storeName,
    this.phoneNumber,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      firstName: json['first_name'],
      lastName: json['last_name'],
      storeName: json['store_name'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'street': street,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'first_name': firstName,
      'last_name': lastName,
      'store_name': storeName,
      'phone_number': phoneNumber,
    };
  }
}
