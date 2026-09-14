class RentPaymentModel {
  final String id;
  final String rentChargeId;
  final String? leaseId;
  final String? propertyId;
  final String? propertyTitle;
  final String? tenantUserId;
  final String? tenantName;
  final double amount;
  final String? paidAt;
  final String? paymentReference;
  final String status;
  final String? chargeStatus;
  final String? createdAt;

  const RentPaymentModel({
    required this.id,
    required this.rentChargeId,
    this.leaseId,
    this.propertyId,
    this.propertyTitle,
    this.tenantUserId,
    this.tenantName,
    required this.amount,
    this.paidAt,
    this.paymentReference,
    required this.status,
    this.chargeStatus,
    this.createdAt,
  });

  factory RentPaymentModel.fromJson(Map<String, dynamic> json) {
    return RentPaymentModel(
      id: json['id'].toString(),
      rentChargeId: json['rentChargeId'].toString(),
      leaseId: json['leaseId']?.toString(),
      propertyId: json['propertyId']?.toString(),
      propertyTitle: json['propertyTitle']?.toString(),
      tenantUserId: json['tenantUserId']?.toString(),
      tenantName: json['tenantName']?.toString(),
      amount: (json['amount'] as num).toDouble(),
      paidAt: json['paidAt']?.toString(),
      paymentReference: json['paymentReference']?.toString(),
      status: json['status'].toString(),
      chargeStatus: json['chargeStatus']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}
