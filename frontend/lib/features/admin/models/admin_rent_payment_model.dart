class AdminRentPaymentModel {
  final String id;
  final String rentChargeId;
  final double amount;
  final String? paidAt;
  final String? paymentReference;
  final String status;

  const AdminRentPaymentModel({
    required this.id,
    required this.rentChargeId,
    required this.amount,
    this.paidAt,
    this.paymentReference,
    required this.status,
  });

  factory AdminRentPaymentModel.fromJson(Map<String, dynamic> json) {
    return AdminRentPaymentModel(
      id: json['id'].toString(),
      rentChargeId: json['rentChargeId'].toString(),
      amount: (json['amount'] as num).toDouble(),
      paidAt: json['paidAt']?.toString(),
      paymentReference: json['paymentReference']?.toString(),
      status: json['status'].toString(),
    );
  }
}