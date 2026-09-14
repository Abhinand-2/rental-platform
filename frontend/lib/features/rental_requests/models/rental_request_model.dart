class RentalRequestModel {
  final String id;
  final String propertyId;
  final String? propertyTitle;
  final String applicantUserId;
  final String? applicantName;
  final String? applicantEmail;
  final String? message;
  final String requestedStartDate;
  final String status;
  final bool leaseExists;
  final String? createdAt;
  final String? updatedAt;

  const RentalRequestModel({
    required this.id,
    required this.propertyId,
    this.propertyTitle,
    required this.applicantUserId,
    this.applicantName,
    this.applicantEmail,
    this.message,
    required this.requestedStartDate,
    required this.status,
    this.leaseExists = false,
    this.createdAt,
    this.updatedAt,
  });

  factory RentalRequestModel.fromJson(Map<String, dynamic> json) {
    return RentalRequestModel(
      id: json['id'].toString(),
      propertyId: json['propertyId'].toString(),
      propertyTitle: json['propertyTitle']?.toString(),
      applicantUserId: json['applicantUserId'].toString(),
      applicantName: json['applicantName']?.toString(),
      applicantEmail: json['applicantEmail']?.toString(),
      message: json['message']?.toString(),
      requestedStartDate: json['requestedStartDate'].toString(),
      status: json['status'].toString(),
      leaseExists: json['leaseExists'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  String get displayApplicantName {
    final value = applicantName?.trim();
    return value == null || value.isEmpty ? 'Applicant' : value;
  }

  String get displayPropertyTitle {
    final value = propertyTitle?.trim();
    return value == null || value.isEmpty ? 'Property' : value;
  }
}
