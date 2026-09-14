class RentChargeModel {
  final String id;
  final String leaseId;
  final String? propertyId;
  final String? propertyTitle;
  final String? tenantUserId;
  final String? tenantName;
  final String? ownerId;
  final String? ownerName;
  final int billingYear;
  final int billingMonth;
  final double amount;
  final String dueDate;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const RentChargeModel({
    required this.id,
    required this.leaseId,
    this.propertyId,
    this.propertyTitle,
    this.tenantUserId,
    this.tenantName,
    this.ownerId,
    this.ownerName,
    required this.billingYear,
    required this.billingMonth,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RentChargeModel.fromJson(Map<String, dynamic> json) {
    return RentChargeModel(
      id: json['id'].toString(),
      leaseId: json['leaseId'].toString(),
      propertyId: json['propertyId']?.toString(),
      propertyTitle: json['propertyTitle']?.toString(),
      tenantUserId: json['tenantUserId']?.toString(),
      tenantName: json['tenantName']?.toString(),
      ownerId: json['ownerId']?.toString(),
      ownerName: json['ownerName']?.toString(),
      billingYear: (json['billingYear'] as num).toInt(),
      billingMonth: (json['billingMonth'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      dueDate: json['dueDate'].toString(),
      status: json['status'].toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  String get monthLabel {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];

    if (billingMonth < 1 || billingMonth > 12) {
      return '$billingMonth/$billingYear';
    }

    return '${months[billingMonth - 1]} $billingYear';
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
