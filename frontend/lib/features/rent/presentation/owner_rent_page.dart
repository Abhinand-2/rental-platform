import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme.dart';

import '../../../core/widgets/app_ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../leases/providers/lease_provider.dart';
import '../../properties/providers/property_provider.dart';
import '../../rental_requests/providers/rental_request_provider.dart';
import '../models/rent_charge_model.dart';
import '../models/rent_payment_model.dart';
import '../providers/rent_provider.dart';

class OwnerRentPage extends ConsumerWidget {
  const OwnerRentPage({super.key});

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref,
    RentChargeModel charge,
  ) async {
    final referenceController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Record Rent Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record ₹${charge.amount.toStringAsFixed(2)} as paid for ${charge.monthLabel}?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Payment reference (optional)',
                    hintText: 'Transaction/reference number',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Record Payment'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      await ref.read(rentRepositoryProvider).recordPayment(
            rentChargeId: charge.id,
            amount: charge.amount,
            paymentReference:
                referenceController.text.trim().isEmpty
                    ? null
                    : referenceController.text.trim(),
          );

      _invalidateOwnerData(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded and rent marked as paid.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record payment: $e')),
        );
      }
    } finally {
      referenceController.dispose();
    }
  }

  void _invalidateOwnerData(WidgetRef ref) {
    final user = ref.read(authProvider).user;
    if (user != null) {
      ref.invalidate(ownerPropertiesProvider(user.id));
    }
    ref.invalidate(ownerRentalRequestsProvider);
    ref.invalidate(ownerLeasesProvider);
    ref.invalidate(ownerRentChargesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentAsync = ref.watch(ownerRentChargesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent & Payments'),
      ),
      body: rentAsync.when(
        loading: () => const LoadingState(),
        error: (error, stackTrace) => ErrorState(
          message: 'Unable to load rent information.',
          onRetry: () => ref.invalidate(ownerRentChargesProvider),
        ),
        data: (charges) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ownerRentChargesProvider);
              await ref.read(ownerRentChargesProvider.future);
            },
            child: _RentContent(
              charges: charges,
              onRecordPayment: (charge) =>
                  _recordPayment(context, ref, charge),
            ),
          );
        },
      ),
    );
  }
}

class _RentContent extends StatelessWidget {
  final List<RentChargeModel> charges;
  final ValueChanged<RentChargeModel> onRecordPayment;

  const _RentContent({
    required this.charges,
    required this.onRecordPayment,
  });

  @override
  Widget build(BuildContext context) {
    final activeCharges =
        charges.where((charge) => charge.status != 'CANCELLED').toList();
    final paid =
        activeCharges.where((charge) => charge.status == 'PAID').toList();
    final pending =
        activeCharges.where((charge) => charge.status == 'PENDING').toList();
    final overdue =
        activeCharges.where((charge) => charge.status == 'OVERDUE').toList();

    final totalAmount = activeCharges.fold<double>(
      0,
      (sum, charge) => sum + charge.amount,
    );
    final paidAmount = paid.fold<double>(
      0,
      (sum, charge) => sum + charge.amount,
    );
    final pendingAmount = pending.fold<double>(
      0,
      (sum, charge) => sum + charge.amount,
    );
    final overdueAmount = overdue.fold<double>(
      0,
      (sum, charge) => sum + charge.amount,
    );

    return AppPage(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(
              title: 'Rent overview',
              subtitle: 'Track expected, collected and outstanding rent.',
            ),
            const SizedBox(height: 20),
            ResponsiveGrid(
              children: [
                StatCard(
                  title: 'Expected',
                  value: _money(totalAmount),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                StatCard(
                  title: 'Collected',
                  value: _money(paidAmount),
                  icon: Icons.check_circle_outline,
                ),
                StatCard(
                  title: 'Pending',
                  value: _money(pendingAmount),
                  icon: Icons.schedule_outlined,
                ),
                StatCard(
                  title: 'Overdue',
                  value: _money(overdueAmount),
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppCard(
              child: _PaymentSummary(
                paid: paid.length,
                pending: pending.length,
                overdue: overdue.length,
              ),
            ),
            const SizedBox(height: 24),
            AppSectionHeader(
              title: 'Rent charges',
              subtitle: '${activeCharges.length} charge(s)',
            ),
            const SizedBox(height: 12),
            if (activeCharges.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No rent charges',
                message: 'Charges appear here when an active lease has rent due.',
              )
            else
              ...activeCharges.map(
                (charge) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RentChargeCard(
                    charge: charge,
                    onRecordPayment: charge.status == 'PAID'
                        ? null
                        : () => onRecordPayment(charge),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _money(double amount) =>
      '₹${amount.toStringAsFixed(0)}';
}

class _PaymentSummary extends StatelessWidget {
  final int paid;
  final int pending;
  final int overdue;

  const _PaymentSummary({
    required this.paid,
    required this.pending,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    final total = paid + pending + overdue;

    if (total == 0) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No payment data available')),
      );
    }

    final paidRatio = paid / total;
    final pendingRatio = pending / total;
    final overdueRatio = overdue / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                if (paidRatio > 0)
                  Expanded(
                    flex: (paidRatio * 100).round().clamp(1, 100),
                    child: Container(color: AppTheme.success),
                  ),
                if (pendingRatio > 0)
                  Expanded(
                    flex: (pendingRatio * 100).round().clamp(1, 100),
                    child: Container(color: AppTheme.warning),
                  ),
                if (overdueRatio > 0)
                  Expanded(
                    flex: (overdueRatio * 100).round().clamp(1, 100),
                    child: Container(color: AppTheme.danger),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _LegendItem(label: 'Paid', count: paid, color: AppTheme.success),
            _LegendItem(
              label: 'Pending',
              count: pending,
              color: AppTheme.warning,
            ),
            _LegendItem(
              label: 'Overdue',
              count: overdue,
              color: AppTheme.danger,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('$label ($count)'),
      ],
    );
  }
}

class _RentChargeCard extends StatelessWidget {
  final RentChargeModel charge;
  final VoidCallback? onRecordPayment;

  const _RentChargeCard({
    required this.charge,
    required this.onRecordPayment,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  charge.monthLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              StatusBadge(status: charge.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            charge.displayPropertyTitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tenant: ${charge.displayTenantName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '₹${charge.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Due ${charge.dueDate}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          if (onRecordPayment != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onRecordPayment,
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Record Payment'),
              ),
            ),
          ],
        ],
      ),
    );
  }

}
