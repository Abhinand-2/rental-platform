import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_provider.dart';

class AdminRentalRequestsPage extends ConsumerWidget {
  const AdminRentalRequestsPage({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final requestsAsync =
        ref.watch(adminRentalRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Requests'),
      ),
      body: requestsAsync.when(
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
                'Failed to load rental requests',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    adminRentalRequestsProvider,
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No rental requests found.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                adminRentalRequestsProvider,
              );

              await ref.read(
                adminRentalRequestsProvider.future,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final color =
                    _statusColor(request.status);

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
                              Icons.assignment_outlined,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Rental Request',
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
                                request.status,
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
                          label: 'Request ID',
                          value: request.id,
                        ),

                        _InfoRow(
                          label: 'Applicant ID',
                          value:
                              request.displayApplicantName,
                        ),

                        _InfoRow(
                          label: 'Property ID',
                          value:
                              request.displayPropertyTitle,
                        ),

                        _InfoRow(
                          label: 'Requested Start',
                          value: request
                              .requestedStartDate
                              .toString()
                              .split(' ')
                              .first,
                        ),

                        if (request.message != null &&
                            request.message!
                                .trim()
                                .isNotEmpty)
                          _InfoRow(
                            label: 'Message',
                            value: request.message!,
                          ),

                        if (request.createdAt != null)
                          _InfoRow(
                            label: 'Created',
                            value:
                                request.createdAt!,
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