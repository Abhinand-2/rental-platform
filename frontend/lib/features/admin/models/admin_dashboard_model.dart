class AdminDashboardModel {
  final int totalUsers;
  final int totalOwners;
  final int totalTenants;

  final int totalProperties;
  final int pendingProperties;
  final int publishedProperties;

  final int activeLeases;

  final int totalRentalRequests;
  final int pendingRentalRequests;

  final int totalRentCharges;
  final int paidRentCharges;
  final int overdueRentCharges;

  final double totalRentAmount;
  final double paidRentAmount;
  final double overdueRentAmount;

  const AdminDashboardModel({
    required this.totalUsers,
    required this.totalOwners,
    required this.totalTenants,
    required this.totalProperties,
    required this.pendingProperties,
    required this.publishedProperties,
    required this.activeLeases,
    required this.totalRentalRequests,
    required this.pendingRentalRequests,
    required this.totalRentCharges,
    required this.paidRentCharges,
    required this.overdueRentCharges,
    required this.totalRentAmount,
    required this.paidRentAmount,
    required this.overdueRentAmount,
  });

  factory AdminDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminDashboardModel(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalOwners: (json['totalOwners'] as num?)?.toInt() ?? 0,
      totalTenants: (json['totalTenants'] as num?)?.toInt() ?? 0,

      totalProperties:
          (json['totalProperties'] as num?)?.toInt() ?? 0,
      pendingProperties:
          (json['pendingProperties'] as num?)?.toInt() ?? 0,
      publishedProperties:
          (json['publishedProperties'] as num?)?.toInt() ?? 0,

      activeLeases:
          (json['activeLeases'] as num?)?.toInt() ?? 0,

      totalRentalRequests:
          (json['totalRentalRequests'] as num?)?.toInt() ?? 0,
      pendingRentalRequests:
          (json['pendingRentalRequests'] as num?)?.toInt() ?? 0,

      totalRentCharges:
          (json['totalRentCharges'] as num?)?.toInt() ?? 0,
      paidRentCharges:
          (json['paidRentCharges'] as num?)?.toInt() ?? 0,
      overdueRentCharges:
          (json['overdueRentCharges'] as num?)?.toInt() ?? 0,

      totalRentAmount:
          (json['totalRentAmount'] as num?)?.toDouble() ?? 0,
      paidRentAmount:
          (json['paidRentAmount'] as num?)?.toDouble() ?? 0,
      overdueRentAmount:
          (json['overdueRentAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}