class CreateRentalRequest {
  final String propertyId;
  final String? message;
  final DateTime requestedStartDate;

  CreateRentalRequest({
    required this.propertyId,
    this.message,
    required this.requestedStartDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'message': message,
      'requestedStartDate':
          requestedStartDate.toIso8601String().split('T').first,
    };
  }
}