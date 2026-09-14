class AdminRentChargeModel {
  final String id;
  final String leaseId;
  final int billingYear;
  final int billingMonth;
  final double amount;
  final String dueDate;
  final String status;

  const AdminRentChargeModel({
    required this.id,
    required this.leaseId,
    required this.billingYear,
    required this.billingMonth,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  factory AdminRentChargeModel.fromJson(Map<String, dynamic> json) {
    return AdminRentChargeModel(
      id: json['id'].toString(),
      leaseId: json['leaseId'].toString(),
      billingYear: (json['billingYear'] as num).toInt(),
      billingMonth: (json['billingMonth'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      dueDate: json['dueDate'].toString(),
      status: json['status'].toString(),
    );
  }
}