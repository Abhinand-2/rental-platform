import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_provider.dart';

class AdminLeasesPage extends ConsumerWidget {
  const AdminLeasesPage({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'EXPIRED':
        return Colors.orange;
      case 'TERMINATED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      case 'DRAFT':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final leasesAsync =
        ref.watch(adminLeasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leases'),
      ),
      body: leasesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load leases',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    adminLeasesProvider,
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (leases) {
          if (leases.isEmpty) {
            return const Center(
              child: Text(
                'No leases found.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                adminLeasesProvider,
              );

              await ref.read(
                adminLeasesProvider.future,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leases.length,
              itemBuilder: (context, index) {
                final lease = leases[index];

                final color =
                    _statusColor(lease.status);

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.description_outlined,
                            ),
                            const SizedBox(width: 8),
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
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    color.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                lease.status,
                                style: TextStyle(
                                  color: color,
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _InfoRow(
                          label: 'Property ID',
                          value: lease.displayPropertyTitle,
                        ),

                        _InfoRow(
                          label: 'Tenant ID',
                          value: lease.displayTenantName,
                        ),

                        _InfoRow(
                          label: 'Owner ID',
                          value: lease.ownerName ?? 'Owner',
                        ),

                        _InfoRow(
                          label: 'Start Date',
                          value: lease.startDate,
                        ),

                        _InfoRow(
                          label: 'End Date',
                          value: lease.endDate,
                        ),

                        _InfoRow(
                          label: 'Monthly Rent',
                          value:
                              '₹${lease.monthlyRent.toStringAsFixed(0)}',
                        ),

                        if (lease.securityDeposit != null)
                          _InfoRow(
                            label: 'Security Deposit',
                            value:
                                '₹${lease.securityDeposit!.toStringAsFixed(0)}',
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium,
          ),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }
}