package rental_platform_backend.dashboard.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import rental_platform_backend.dashboard.dto.AdminDashboardResponse;

import java.math.BigDecimal;
import java.util.Map;

@Service
public class AdminDashboardService {

    private final JdbcTemplate jdbcTemplate;

    public AdminDashboardService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public AdminDashboardResponse getDashboardStatistics() {

        String sql = """
                SELECT
                    (SELECT COUNT(*)
                     FROM users) AS total_users,

                    (SELECT COUNT(*)
                     FROM users
                     WHERE role = 'OWNER') AS total_owners,

                    (SELECT COUNT(*)
                     FROM tenants) AS total_tenants,

                    (SELECT COUNT(*)
                     FROM properties) AS total_properties,

                    (SELECT COUNT(*)
                     FROM properties
                     WHERE status = 'PENDING_APPROVAL') AS pending_properties,

                    (SELECT COUNT(*)
                     FROM properties
                     WHERE status = 'PUBLISHED') AS published_properties,

(SELECT COUNT(*)
 FROM properties
 WHERE status = 'RENTED') AS rented_properties,

                    (SELECT COUNT(*)
                     FROM leases
                     WHERE status = 'ACTIVE') AS active_leases,

                    (SELECT COUNT(*)
                     FROM rental_requests) AS total_rental_requests,

                    (SELECT COUNT(*)
                     FROM rental_requests
                     WHERE status = 'PENDING') AS pending_rental_requests,

                    (SELECT COUNT(*)
                     FROM rent_charges) AS total_rent_charges,

                    (SELECT COUNT(*)
                     FROM rent_charges
                     WHERE status = 'PAID') AS paid_rent_charges,

                    (SELECT COUNT(*)
                     FROM rent_charges
                     WHERE status = 'OVERDUE') AS overdue_rent_charges,

                    (SELECT COALESCE(SUM(amount), 0)
                     FROM rent_charges
                     WHERE status <> 'CANCELLED') AS total_rent_amount,

                    (SELECT COALESCE(SUM(amount), 0)
                     FROM rent_charges
                     WHERE status = 'PAID') AS paid_rent_amount,

                    (SELECT COALESCE(SUM(amount), 0)
                     FROM rent_charges
                     WHERE status = 'OVERDUE') AS overdue_rent_amount
                """;

        Map<String, Object> row = jdbcTemplate.queryForMap(sql);

        return new AdminDashboardResponse(
                getLong(row, "total_users"),
                getLong(row, "total_owners"),
                getLong(row, "total_tenants"),

                getLong(row, "total_properties"),
                getLong(row, "pending_properties"),
                getLong(row, "published_properties"),
                getLong(row, "rented_properties"),

                getLong(row, "active_leases"),

                getLong(row, "total_rental_requests"),
                getLong(row, "pending_rental_requests"),

                getLong(row, "total_rent_charges"),
                getLong(row, "paid_rent_charges"),
                getLong(row, "overdue_rent_charges"),

                getBigDecimal(row, "total_rent_amount"),
                getBigDecimal(row, "paid_rent_amount"),
                getBigDecimal(row, "overdue_rent_amount")
        );
    }

    private long getLong(
            Map<String, Object> row,
            String key
    ) {
        Number value = (Number) row.get(key);
        return value == null ? 0L : value.longValue();
    }

    private BigDecimal getBigDecimal(
            Map<String, Object> row,
            String key
    ) {
        Object value = row.get(key);

        if (value == null) {
            return BigDecimal.ZERO;
        }

        if (value instanceof BigDecimal decimal) {
            return decimal;
        }

        if (value instanceof Number number) {
            return BigDecimal.valueOf(number.doubleValue());
        }

        return new BigDecimal(value.toString());
    }
}