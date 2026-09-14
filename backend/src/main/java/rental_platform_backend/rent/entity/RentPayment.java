package rental_platform_backend.rent.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "rent_payments",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uq_rent_payment_charge",
                        columnNames = "rent_charge_id"
                )
        }
)
public class RentPayment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "rent_charge_id", nullable = false, unique = true)
    private RentCharge rentCharge;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Column(name = "paid_at", nullable = false)
    private LocalDateTime paidAt;

    @Column(name = "payment_reference", length = 100)
    private String paymentReference;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RentPaymentStatus status;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public RentPayment() {
    }

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();

        createdAt = now;

        if (paidAt == null) {
            paidAt = now;
        }

        if (status == null) {
            status = RentPaymentStatus.SUCCESS;
        }
    }

    public UUID getId() {
        return id;
    }

    public RentCharge getRentCharge() {
        return rentCharge;
    }

    public void setRentCharge(RentCharge rentCharge) {
        this.rentCharge = rentCharge;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }

    public String getPaymentReference() {
        return paymentReference;
    }

    public void setPaymentReference(String paymentReference) {
        this.paymentReference = paymentReference;
    }

    public RentPaymentStatus getStatus() {
        return status;
    }

    public void setStatus(RentPaymentStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}