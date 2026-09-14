import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_provider.dart';

class AdminRentPage extends ConsumerWidget {
  const AdminRentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chargesAsync = ref.watch(adminRentChargesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Management'),
      ),
      body: chargesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load rent charges'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(adminRentChargesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (charges) {
          if (charges.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminRentChargesProvider);
                await ref.read(
                  adminRentChargesProvider.future,
                );
              },
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(
                    child: Text('No rent charges found.'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminRentChargesProvider);
              await ref.read(
                adminRentChargesProvider.future,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: charges.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final charge = charges[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Rent Charge',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                              ),
                            ),
                            _StatusBadge(
                              status: charge.status,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '₹${charge.amount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Billing: '
                          '${charge.billingMonth}/'
                          '${charge.billingYear}',
                        ),
                        Text(
                          'Due date: ${charge.dueDate}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rent charge',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showPayment(
                                    context,
                                    ref,
                                    charge.id,
                                  );
                                },
                                icon: const Icon(
                                  Icons.payment_outlined,
                                ),
                                label: const Text(
                                  'View Payment',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    charge.status == 'PAID'
                                        ? null
                                        : () {
                                            _showRecordPayment(
                                              context,
                                              ref,
                                              charge.id,
                                              charge.amount,
                                            );
                                          },
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                ),
                                label: const Text(
                                  'Record Payment',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showPayment(
    BuildContext context,
    WidgetRef ref,
    String chargeId,
  ) async {
    try {
      final payment = await ref
          .read(adminRentRepositoryProvider)
          .getPaymentForCharge(chargeId);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (_) {
          if (payment == null) {
            return AlertDialog(
              title: const Text('Payment'),
              content: const Text(
                'No payment has been recorded for this charge.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Payment Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: ₹${payment.amount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                Text('Status: ${payment.status}'),
                if (payment.paidAt != null) ...[
                  const SizedBox(height: 8),
                  Text('Paid at: ${payment.paidAt}'),
                ],
                if (payment.paymentReference != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reference: '
                    '${payment.paymentReference}',
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load payment details.'),
        ),
      );
    }
  }

  Future<void> _showRecordPayment(
    BuildContext context,
    WidgetRef ref,
    String chargeId,
    double chargeAmount,
  ) async {
    final amountController = TextEditingController(
      text: chargeAmount.toStringAsFixed(2),
    );

    final referenceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(
                  labelText: 'Payment Reference',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(
                  amountController.text.trim(),
                );

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a valid payment amount.',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await ref
                      .read(adminRentRepositoryProvider)
                      .recordPayment(
                        rentChargeId: chargeId,
                        amount: amount,
                        paymentReference:
                            referenceController.text
                                    .trim()
                                    .isEmpty
                                ? null
                                : referenceController.text
                                    .trim(),
                      );

                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to record payment.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    amountController.dispose();
    referenceController.dispose();

    if (result == true) {
      ref.invalidate(adminRentChargesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully.'),
          ),
        );
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}