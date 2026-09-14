import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rental_request_model.dart';
import '../providers/rental_request_provider.dart';

class MyRentalRequestsPage extends ConsumerWidget {
  const MyRentalRequestsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync =
        ref.watch(myRentalRequestsProvider);

    return requestsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      error: (error, stackTrace) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load your rental requests.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      myRentalRequestsProvider,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },

      data: (requests) {
        if (requests.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myRentalRequestsProvider);

              await ref.read(
                myRentalRequestsProvider.future,
              );
            },
            child: ListView(
              children: const [
                SizedBox(height: 180),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 56,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'You have no rental requests yet.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myRentalRequestsProvider);

            await ref.read(
              myRentalRequestsProvider.future,
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return RentalRequestCard(
                request: requests[index],
              );
            },
          ),
        );
      },
    );
  }
}

class RentalRequestCard extends StatelessWidget {
  final RentalRequestModel request;

  const RentalRequestCard({
    super.key,
    required this.request,
  });

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;

      case 'REJECTED':
        return Colors.red;

      case 'CANCELLED':
        return Colors.grey;

      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _statusColor(context, request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.home_work_outlined,
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Rental Request',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _InfoRow(
              label: 'Requested start',
              value: request.requestedStartDate,
            ),

            if (request.message != null &&
                request.message!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoRow(
                label: 'Message',
                value: request.message!,
              ),
            ],

            const SizedBox(height: 10),

            _InfoRow(
              label: 'Property',
              value: request.displayPropertyTitle,
            ),

            if (request.status == 'APPROVED')
              _InfoRow(
                label: 'Lease',
                value: request.leaseExists
                    ? 'Lease active'
                    : 'Approved - lease pending',
              ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 3),
        Text(value),
      ],
    );
  }
}