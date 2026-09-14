class PropertyImageModel {
  final String id;
  final String propertyId;
  final String imageUrl;
  final int displayOrder;
  final bool primary;

  PropertyImageModel({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    required this.displayOrder,
    required this.primary,
  });

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      imageUrl: json['imageUrl'] as String,
      displayOrder: json['displayOrder'] as int,
      primary: json['primary'] as bool,
    );
  }
}