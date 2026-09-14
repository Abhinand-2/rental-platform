package rental_platform_backend.dashboard.dto;

import java.math.BigDecimal;

public record AdminDashboardResponse(

        long totalUsers,
        long totalOwners,
        long totalTenants,

        long totalProperties,
        long pendingProperties,
        long publishedProperties,
        long rentedProperties,

        long activeLeases,

        long totalRentalRequests,
        long pendingRentalRequests,

        long totalRentCharges,
        long paidRentCharges,
        long overdueRentCharges,

        BigDecimal totalRentAmount,
        BigDecimal paidRentAmount,
        BigDecimal overdueRentAmount
) {
}