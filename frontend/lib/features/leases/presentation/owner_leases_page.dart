import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lease_model.dart';
import '../providers/lease_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../properties/providers/property_provider.dart';
import '../../rental_requests/providers/rental_request_provider.dart';
import '../../rent/providers/rent_provider.dart';

class OwnerLeasesPage extends ConsumerWidget {
  const OwnerLeasesPage({super.key});

  Future<void> _terminateLease(
    BuildContext context,
    WidgetRef ref,
    LeaseModel lease,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terminate Lease'),
          content: const Text(
            'Are you sure you want to terminate this lease?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Terminate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final repository =
          ref.read(leaseRepositoryProvider);

      await repository.terminateLease(lease.id);

      _invalidateOwnerData(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lease terminated successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to terminate lease: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _cancelLease(
    BuildContext context,
    WidgetRef ref,
    LeaseModel lease,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Lease'),
          content: const Text(
            'Are you sure you want to cancel this lease?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Cancel Lease'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final repository =
          ref.read(leaseRepositoryProvider);

      await repository.cancelLease(lease.id);

      _invalidateOwnerData(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lease cancelled successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to cancel lease: $e',
            ),
          ),
        );
      }
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
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final leasesAsync =
        ref.watch(ownerLeasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leases'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _invalidateOwnerData(ref);
          await ref.read(ownerLeasesProvider.future);
        },
        child: leasesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) =>
              ListView(
            children: [
              const SizedBox(height: 100),
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load leases.',
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(
                          ownerLeasesProvider,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          data: (leases) {
            if (leases.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 56,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No leases yet.',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: leases.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lease = leases[index];

                return _LeaseCard(
                  lease: lease,
                  onTerminate:
                      lease.status == 'ACTIVE'
                          ? () {
                              _terminateLease(
                                context,
                                ref,
                                lease,
                              );
                            }
                          : null,
                  onCancel:
                      lease.status == 'ACTIVE'
                          ? () {
                              _cancelLease(
                                context,
                                ref,
                                lease,
                              );
                            }
                          : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LeaseCard extends StatelessWidget {
  final LeaseModel lease;
  final VoidCallback? onTerminate;
  final VoidCallback? onCancel;

  const _LeaseCard({
    required this.lease,
    this.onTerminate,
    this.onCancel,
  });

  Color _statusColor(BuildContext context) {
    switch (lease.status) {
      case 'ACTIVE':
        return Colors.green;
      case 'EXPIRED':
        return Colors.orange;
      case 'TERMINATED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Theme.of(context)
            .colorScheme
            .primary;
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
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lease',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        statusColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    lease.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _InfoRow(
              label: 'Property',
              value: lease.displayPropertyTitle,
            ),

            _InfoRow(
              label: 'Tenant',
              value: lease.displayTenantName,
            ),

            _InfoRow(
              label: 'Start',
              value: lease.startDate,
            ),

            _InfoRow(
              label: 'End',
              value: lease.endDate,
            ),

            _InfoRow(
              label: 'Monthly Rent',
              value:
                  '₹${lease.monthlyRent.toStringAsFixed(2)}',
            ),

            if (lease.securityDeposit != null)
              _InfoRow(
                label: 'Security Deposit',
                value:
                    '₹${lease.securityDeposit!.toStringAsFixed(2)}',
              ),

            if (onTerminate != null ||
                onCancel != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  if (onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                  if (onTerminate != null)
                    OutlinedButton(
                      onPressed: onTerminate,
                      child: const Text(
                        'Terminate',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

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
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}