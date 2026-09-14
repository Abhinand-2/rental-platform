class LeaseModel {
  final String id;
  final String rentalRequestId;
  final String propertyId;
  final String? propertyTitle;
  final String tenantId;
  final String tenantUserId;
  final String? tenantName;
  final String? tenantEmail;
  final String ownerId;
  final String? ownerName;
  final String? ownerEmail;
  final String startDate;
  final String endDate;
  final double monthlyRent;
  final double? securityDeposit;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const LeaseModel({
    required this.id,
    required this.rentalRequestId,
    required this.propertyId,
    this.propertyTitle,
    required this.tenantId,
    required this.tenantUserId,
    this.tenantName,
    this.tenantEmail,
    required this.ownerId,
    this.ownerName,
    this.ownerEmail,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    this.securityDeposit,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaseModel.fromJson(Map<String, dynamic> json) {
    return LeaseModel(
      id: json['id'].toString(),
      rentalRequestId: json['rentalRequestId'].toString(),
      propertyId: json['propertyId'].toString(),
      propertyTitle: json['propertyTitle']?.toString(),
      tenantId: json['tenantId'].toString(),
      tenantUserId: json['tenantUserId']?.toString() ?? json['tenantId'].toString(),
      tenantName: json['tenantName']?.toString(),
      tenantEmail: json['tenantEmail']?.toString(),
      ownerId: json['ownerId'].toString(),
      ownerName: json['ownerName']?.toString(),
      ownerEmail: json['ownerEmail']?.toString(),
      startDate: json['startDate'].toString(),
      endDate: json['endDate'].toString(),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      securityDeposit: json['securityDeposit'] == null
          ? null
          : (json['securityDeposit'] as num).toDouble(),
      status: json['status'].toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  String get displayPropertyTitle {
    final value = propertyTitle?.trim();
    return value == null || value.isEmpty ? 'Property' : value;
  }

  String get displayTenantName {
    final value = tenantName?.trim();
    return value == null || value.isEmpty ? 'Tenant' : value;
  }
}
