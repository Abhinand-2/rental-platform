class CreatePropertyRequest {
  final String title;
  final String? description;
  final String type;
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

  CreatePropertyRequest({
    required this.title,
    this.description,
    required this.type,
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
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaSqFt': areaSqFt,
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
    };
  }
}