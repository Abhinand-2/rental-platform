class PropertyModel {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String type;
  final String status;
  final String addressLine;
  final String city;
  final String state;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final int? bedrooms;
  final int? bathrooms;
  final double? areaSqFt;
  final double monthlyRent;
  final double? securityDeposit;
  final String? createdAt;
  final String? updatedAt;

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    this.latitude,
    this.longitude,
    this.bedrooms,
    this.bathrooms,
    this.areaSqFt,
    required this.monthlyRent,
    this.securityDeposit,
    this.createdAt,
    this.updatedAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      addressLine: json['addressLine'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      areaSqFt: (json['areaSqFt'] as num?)?.toDouble(),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      securityDeposit:
          (json['securityDeposit'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}