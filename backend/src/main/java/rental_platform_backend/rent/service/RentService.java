package rental_platform_backend.rent.service;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import rental_platform_backend.lease.entity.Lease;
import rental_platform_backend.lease.entity.LeaseStatus;
import rental_platform_backend.lease.repository.LeaseRepository;
import rental_platform_backend.rent.dto.CreateRentChargeRequest;
import rental_platform_backend.rent.dto.RecordRentPaymentRequest;
import rental_platform_backend.rent.dto.RentChargeResponse;
import rental_platform_backend.rent.dto.RentPaymentResponse;
import rental_platform_backend.rent.entity.RentCharge;
import rental_platform_backend.rent.entity.RentChargeStatus;
import rental_platform_backend.rent.entity.RentPayment;
import rental_platform_backend.rent.entity.RentPaymentStatus;
import rental_platform_backend.rent.repository.RentChargeRepository;
import rental_platform_backend.rent.repository.RentPaymentRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class RentService {

    private final RentChargeRepository rentChargeRepository;
    private final RentPaymentRepository rentPaymentRepository;
    private final LeaseRepository leaseRepository;

    public RentService(
            RentChargeRepository rentChargeRepository,
            RentPaymentRepository rentPaymentRepository,
            LeaseRepository leaseRepository
    ) {
        this.rentChargeRepository = rentChargeRepository;
        this.rentPaymentRepository = rentPaymentRepository;
        this.leaseRepository = leaseRepository;
    }

    /*
     * ============================================================
     * INITIAL RENT CHARGE
     * ============================================================
     *
     * Called automatically when a lease is created and activated.
     *
     * The first rent charge belongs to the lease start month.
     */
    public void createInitialRentCharge(Lease lease) {

        if (lease == null) {
            throw new IllegalArgumentException(
                    "Lease cannot be null"
            );
        }

        if (lease.getStatus() != LeaseStatus.ACTIVE) {
            throw new IllegalArgumentException(
                    "Rent charge can only be created for an active lease"
            );
        }

        LocalDate startDate = lease.getStartDate();

        int billingYear = startDate.getYear();
        int billingMonth = startDate.getMonthValue();

        boolean alreadyExists =
                rentChargeRepository
                        .existsByLeaseIdAndBillingYearAndBillingMonth(
                                lease.getId(),
                                billingYear,
                                billingMonth
                        );

        if (alreadyExists) {
            return;
        }

        RentCharge rentCharge = new RentCharge();

        rentCharge.setLease(lease);
        rentCharge.setBillingYear(billingYear);
        rentCharge.setBillingMonth(billingMonth);
        rentCharge.setAmount(lease.getMonthlyRent());
        rentCharge.setDueDate(startDate);
        rentCharge.setStatus(RentChargeStatus.PENDING);

        rentChargeRepository.save(rentCharge);
    }


    /*
     * ============================================================
     * CREATE RENT CHARGE
     * ============================================================
     *
     * Manual creation by OWNER or ADMIN.
     */
    public RentChargeResponse createRentCharge(
            CreateRentChargeRequest request,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Lease lease = leaseRepository.findById(request.leaseId())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Lease not found"
                        )
                );

        validateManageAccess(
                lease,
                currentUserId,
                isAdmin
        );

        if (lease.getStatus() != LeaseStatus.ACTIVE) {
            throw new IllegalArgumentException(
                    "Rent charges can only be created for an active lease"
            );
        }

        /*
         * Rent charged must always match the contractual
         * monthly rent defined by the lease.
         */
        if (request.amount().compareTo(
                lease.getMonthlyRent()
        ) != 0) {

            throw new IllegalArgumentException(
                    "Rent charge amount must match the lease monthly rent"
            );
        }

        /*
         * Do not allow duplicate billing periods.
         */
        boolean alreadyExists =
                rentChargeRepository
                        .existsByLeaseIdAndBillingYearAndBillingMonth(
                                lease.getId(),
                                request.billingYear(),
                                request.billingMonth()
                        );

        if (alreadyExists) {
            throw new IllegalArgumentException(
                    "Rent charge already exists for this billing period"
            );
        }

        validateBillingPeriod(
                lease,
                request.billingYear(),
                request.billingMonth()
        );

        RentCharge rentCharge = new RentCharge();

        rentCharge.setLease(lease);
        rentCharge.setBillingYear(request.billingYear());
        rentCharge.setBillingMonth(request.billingMonth());
        rentCharge.setAmount(request.amount());
        rentCharge.setDueDate(request.dueDate());
        rentCharge.setStatus(RentChargeStatus.PENDING);

        RentCharge savedCharge =
                rentChargeRepository.save(rentCharge);

        return toChargeResponse(savedCharge);
    }


    /*
     * ============================================================
     * GET SINGLE RENT CHARGE
     * ============================================================
     */
    @Transactional(readOnly = true)
    public RentChargeResponse getRentCharge(
            UUID chargeId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        RentCharge charge =
                rentChargeRepository.findById(chargeId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Rent charge not found"
                                )
                        );

        validateViewAccess(
                charge.getLease(),
                currentUserId,
                isAdmin
        );

        return toChargeResponse(charge);
    }


    /*
     * ============================================================
     * GET MY RENT CHARGES
     * ============================================================
     *
     * USER/TENANT view.
     */
    @Transactional(readOnly = true)
    public List<RentChargeResponse> getMyCharges(
            UUID currentUserId
    ) {

        return rentChargeRepository
                .findByLeaseTenantUserId(currentUserId)
                .stream()
                .map(this::toChargeResponse)
                .toList();
    }


    /*
     * ============================================================
     * GET OWNER RENT CHARGES
     * ============================================================
     */
    @Transactional(readOnly = true)
    public List<RentChargeResponse> getOwnerCharges(
            UUID ownerId
    ) {

        return rentChargeRepository
                .findByLeaseOwnerId(ownerId)
                .stream()
                .map(this::toChargeResponse)
                .toList();
    }


    /*
     * ============================================================
     * GET ALL RENT CHARGES
     * ============================================================
     *
     * ADMIN only.
     */
    @Transactional(readOnly = true)
    public List<RentChargeResponse> getAllCharges() {

        return rentChargeRepository.findAll()
                .stream()
                .map(this::toChargeResponse)
                .toList();
    }


    /*
     * ============================================================
     * RECORD RENT PAYMENT
     * ============================================================
     */
    public RentPaymentResponse recordPayment(
            RecordRentPaymentRequest request,
            UUID currentUserId,
            boolean isAdmin
    ) {

        RentCharge rentCharge =
                rentChargeRepository.findById(
                        request.rentChargeId()
                ).orElseThrow(() ->
                        new IllegalArgumentException(
                                "Rent charge not found"
                        )
                );

        Lease lease = rentCharge.getLease();

        validateManageAccess(
                lease,
                currentUserId,
                isAdmin
        );

        if (rentCharge.getStatus() ==
                RentChargeStatus.PAID) {

            throw new IllegalArgumentException(
                    "Rent charge has already been paid"
            );
        }

        if (rentCharge.getStatus() ==
                RentChargeStatus.CANCELLED) {

            throw new IllegalArgumentException(
                    "Cannot record payment for a cancelled rent charge"
            );
        }

        /*
         * Only one successful payment is allowed per charge.
         */
        if (rentPaymentRepository
                .existsByRentChargeId(
                        rentCharge.getId()
                )) {

            throw new IllegalArgumentException(
                    "Payment already exists for this rent charge"
            );
        }

        /*
         * Payment must exactly match the rent charge amount.
         */
        if (request.amount().compareTo(
                rentCharge.getAmount()
        ) != 0) {

            throw new IllegalArgumentException(
                    "Payment amount must match the rent charge amount"
            );
        }

        RentPayment payment = new RentPayment();

        payment.setRentCharge(rentCharge);
        payment.setAmount(request.amount());
        payment.setPaidAt(LocalDateTime.now());
        payment.setPaymentReference(
                request.paymentReference()
        );
        payment.setStatus(
                RentPaymentStatus.SUCCESS
        );

        RentPayment savedPayment =
                rentPaymentRepository.save(payment);

        /*
         * Successful payment changes the charge to PAID.
         */
        rentCharge.setStatus(
                RentChargeStatus.PAID
        );

        rentChargeRepository.save(rentCharge);

        return toPaymentResponse(savedPayment);
    }


    /*
     * ============================================================
     * GET PAYMENT BY RENT CHARGE
     * ============================================================
     */
    @Transactional(readOnly = true)
    public RentPaymentResponse getPaymentByCharge(
            UUID chargeId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        RentCharge rentCharge =
                rentChargeRepository.findById(chargeId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Rent charge not found"
                                )
                        );

        validateViewAccess(
                rentCharge.getLease(),
                currentUserId,
                isAdmin
        );

        RentPayment payment =
                rentPaymentRepository
                        .findByRentChargeId(chargeId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Payment not found for this rent charge"
                                )
                        );

        return toPaymentResponse(payment);
    }


    /*
     * ============================================================
     * GET MY PAYMENTS
     * ============================================================
     */
    @Transactional(readOnly = true)
    public List<RentPaymentResponse> getMyPayments(
            UUID currentUserId
    ) {

        return rentPaymentRepository
                .findByRentChargeLeaseTenantUserId(currentUserId)
                .stream()
                .map(this::toPaymentResponse)
                .toList();
    }


    /*
     * ============================================================
     * GET OWNER PAYMENTS
     * ============================================================
     */
    @Transactional(readOnly = true)
    public List<RentPaymentResponse> getOwnerPayments(
            UUID ownerId
    ) {

        return rentPaymentRepository
                .findByRentChargeLeaseOwnerId(ownerId)
                .stream()
                .map(this::toPaymentResponse)
                .toList();
    }


    /*
     * ============================================================
     * AUTOMATIC OVERDUE PROCESSING
     * ============================================================
     *
     * Runs every day at 00:05.
     *
     * Any unpaid PENDING charge whose due date has passed
     * becomes OVERDUE.
     */
    @Scheduled(cron = "0 5 0 * * *")
    public void updateOverdueCharges() {

        LocalDate today = LocalDate.now();

        List<RentCharge> pendingCharges =
                rentChargeRepository.findByStatus(
                        RentChargeStatus.PENDING
                );

        List<RentCharge> overdueCharges =
                pendingCharges.stream()
                        .filter(charge ->
                                charge.getDueDate()
                                        .isBefore(today)
                        )
                        .peek(charge ->
                                charge.setStatus(
                                        RentChargeStatus.OVERDUE
                                )
                        )
                        .toList();

        if (!overdueCharges.isEmpty()) {
            rentChargeRepository.saveAll(
                    overdueCharges
            );
        }
    }


    /*
     * ============================================================
     * AUTOMATIC MONTHLY RENT CHARGE GENERATION
     * ============================================================
     *
     * Runs every day at 00:10.
     *
     * Creates the current month's charge for every ACTIVE lease.
     *
     * The database unique constraint on:
     *
     * (lease_id, billing_year, billing_month)
     *
     * prevents duplicate charges.
     */
    @Scheduled(cron = "0 10 0 * * *")
    public void generateMonthlyRentCharges() {

        LocalDate today = LocalDate.now();

        int billingYear = today.getYear();
        int billingMonth = today.getMonthValue();

        List<Lease> activeLeases =
                leaseRepository.findByStatus(
                        LeaseStatus.ACTIVE
                );

        for (Lease lease : activeLeases) {

            /*
             * Billing period represents the month being charged.
             */
            LocalDate billingDate =
                    LocalDate.of(
                            billingYear,
                            billingMonth,
                            1
                    );

            LocalDate leaseStart =
                    lease.getStartDate()
                            .withDayOfMonth(1);

            LocalDate leaseEnd =
                    lease.getEndDate()
                            .withDayOfMonth(1);

            /*
             * Never create a charge outside the lease period.
             */
            if (billingDate.isBefore(leaseStart) ||
                    billingDate.isAfter(leaseEnd)) {

                continue;
            }

            /*
             * The initial charge may already exist for the
             * lease's starting month.
             */
            boolean alreadyExists =
                    rentChargeRepository
                            .existsByLeaseIdAndBillingYearAndBillingMonth(
                                    lease.getId(),
                                    billingYear,
                                    billingMonth
                            );

            if (alreadyExists) {
                continue;
            }

            /*
             * Use the lease start day as the recurring rent
             * due day.
             *
             * Example:
             * Lease starts on 15th
             * -> October charge due on October 15th
             *
             * If the lease starts on 31st:
             * February -> 28th/29th
             * April    -> 30th
             */
            int rentDueDay =
                    Math.min(
                            lease.getStartDate().getDayOfMonth(),
                            YearMonth.of(
                                    billingYear,
                                    billingMonth
                            ).lengthOfMonth()
                    );

            LocalDate dueDate =
                    LocalDate.of(
                            billingYear,
                            billingMonth,
                            rentDueDay
                    );

            RentCharge rentCharge = new RentCharge();

            rentCharge.setLease(lease);
            rentCharge.setBillingYear(billingYear);
            rentCharge.setBillingMonth(billingMonth);
            rentCharge.setAmount(lease.getMonthlyRent());
            rentCharge.setDueDate(dueDate);
            rentCharge.setStatus(
                    RentChargeStatus.PENDING
            );

            rentChargeRepository.save(rentCharge);
        }
    }


    /*
     * ============================================================
     * ACCESS CONTROL
     * ============================================================
     */

    private void validateManageAccess(
            Lease lease,
            UUID currentUserId,
            boolean isAdmin
    ) {

        if (isAdmin) {
            return;
        }

        if (lease.getOwner() == null ||
                lease.getOwner().getId() == null) {

            throw new IllegalArgumentException(
                    "Lease owner is not configured"
            );
        }

        if (!lease.getOwner()
                .getId()
                .equals(currentUserId)) {

            throw new IllegalArgumentException(
                    "You do not have permission to manage this rent"
            );
        }
    }


    private void validateViewAccess(
            Lease lease,
            UUID currentUserId,
            boolean isAdmin
    ) {

        if (isAdmin) {
            return;
        }

        boolean isOwner =
                lease.getOwner() != null
                        && lease.getOwner().getId() != null
                        && lease.getOwner()
                        .getId()
                        .equals(currentUserId);

        boolean isTenant =
                lease.getTenant() != null
                        && lease.getTenant().getUser() != null
                        && lease.getTenant()
                        .getUser()
                        .getId()
                        .equals(currentUserId);

        if (!isOwner && !isTenant) {
            throw new IllegalArgumentException(
                    "You do not have permission to view this rent information"
            );
        }
    }


    /*
     * ============================================================
     * BILLING PERIOD VALIDATION
     * ============================================================
     */
    private void validateBillingPeriod(
            Lease lease,
            Integer billingYear,
            Integer billingMonth
    ) {

        LocalDate billingDate =
                LocalDate.of(
                        billingYear,
                        billingMonth,
                        1
                );

        LocalDate leaseStart =
                lease.getStartDate()
                        .withDayOfMonth(1);

        LocalDate leaseEnd =
                lease.getEndDate()
                        .withDayOfMonth(1);

        if (billingDate.isBefore(leaseStart) ||
                billingDate.isAfter(leaseEnd)) {

            throw new IllegalArgumentException(
                    "Billing period must fall within the lease period"
            );
        }
    }


    /*
     * ============================================================
     * RENT CHARGE RESPONSE MAPPER
     * ============================================================
     */
    private RentChargeResponse toChargeResponse(
            RentCharge charge
    ) {

        Lease lease = charge.getLease();

        String propertyTitle =
                lease.getProperty() != null
                        ? lease.getProperty().getTitle()
                        : null;

        UUID propertyId =
                lease.getProperty() != null
                        ? lease.getProperty().getId()
                        : null;

        UUID tenantUserId = null;
        String tenantName = null;

        if (lease.getTenant() != null &&
                lease.getTenant().getUser() != null) {

            tenantUserId =
                    lease.getTenant()
                            .getUser()
                            .getId();

            tenantName =
                    buildFullName(
                            lease.getTenant()
                                    .getUser()
                                    .getFirstName(),
                            lease.getTenant()
                                    .getUser()
                                    .getLastName()
                    );
        }

        UUID ownerId = null;
        String ownerName = null;

        if (lease.getOwner() != null) {

            ownerId =
                    lease.getOwner().getId();

            ownerName =
                    buildFullName(
                            lease.getOwner().getFirstName(),
                            lease.getOwner().getLastName()
                    );
        }

        return new RentChargeResponse(
                charge.getId(),
                lease.getId(),
                propertyId,
                propertyTitle,
                tenantUserId,
                tenantName,
                ownerId,
                ownerName,
                charge.getBillingYear(),
                charge.getBillingMonth(),
                charge.getAmount(),
                charge.getDueDate(),
                charge.getStatus(),
                charge.getCreatedAt(),
                charge.getUpdatedAt()
        );
    }


    /*
     * ============================================================
     * RENT PAYMENT RESPONSE MAPPER
     * ============================================================
     */
    private RentPaymentResponse toPaymentResponse(
            RentPayment payment
    ) {

        RentCharge charge =
                payment.getRentCharge();

        Lease lease =
                charge.getLease();

        String propertyTitle =
                lease.getProperty() != null
                        ? lease.getProperty().getTitle()
                        : null;

        UUID propertyId =
                lease.getProperty() != null
                        ? lease.getProperty().getId()
                        : null;

        UUID tenantUserId = null;
        String tenantName = null;

        if (lease.getTenant() != null &&
                lease.getTenant().getUser() != null) {

            tenantUserId =
                    lease.getTenant()
                            .getUser()
                            .getId();

            tenantName =
                    buildFullName(
                            lease.getTenant()
                                    .getUser()
                                    .getFirstName(),
                            lease.getTenant()
                                    .getUser()
                                    .getLastName()
                    );
        }

        return new RentPaymentResponse(
                payment.getId(),
                charge.getId(),
                lease.getId(),
                propertyId,
                propertyTitle,
                tenantUserId,
                tenantName,
                payment.getAmount(),
                payment.getPaidAt(),
                payment.getPaymentReference(),
                payment.getStatus(),
                charge.getStatus(),
                payment.getCreatedAt()
        );
    }


    /*
     * ============================================================
     * FULL NAME HELPER
     * ============================================================
     */
    private String buildFullName(
            String firstName,
            String lastName
    ) {

        String first =
                firstName == null
                        ? ""
                        : firstName.trim();

        String last =
                lastName == null
                        ? ""
                        : lastName.trim();

        return (first + " " + last).trim();
    }
}