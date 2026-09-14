import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../leases/presentation/create_lease_page.dart';
import '../../leases/providers/lease_provider.dart';
import '../../rent/providers/rent_provider.dart';
import '../../properties/providers/property_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rental_requests/models/rental_request_model.dart';
import '../../rental_requests/providers/rental_request_provider.dart';

class OwnerRentalRequestsPage extends ConsumerWidget {
  const OwnerRentalRequestsPage({super.key});

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    RentalRequestModel request,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Text(
          'Approve the rental request from ${request.displayApplicantName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(rentalRequestRepositoryProvider)
          .approveRentalRequest(request.id);

      _invalidateOwnerData(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rental request approved.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to approve request: $e');
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    RentalRequestModel request,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Text(
          'Reject the rental request from ${request.displayApplicantName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(rentalRequestRepositoryProvider)
          .rejectRentalRequest(request.id);

      _invalidateOwnerData(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rental request rejected.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to reject request: $e');
      }
    }
  }

  Future<void> _createLease(
    BuildContext context,
    WidgetRef ref,
    RentalRequestModel request,
  ) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateLeasePage(rentalRequest: request),
      ),
    );

    if (created == true) {
      _invalidateOwnerData(ref);
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(ownerRentalRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Requests')),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load rental requests'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(ownerRentalRequestsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(ownerRentalRequestsProvider);
                await ref.read(ownerRentalRequestsProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('No rental requests yet.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ownerRentalRequestsProvider);
              await ref.read(ownerRentalRequestsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final statusColor = _statusColor(request.status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                request.displayApplicantName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            _StatusChip(
                              status: request.status,
                              color: statusColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          label: 'Property',
                          value: request.displayPropertyTitle,
                        ),
                        _InfoRow(
                          label: 'Requested start',
                          value: request.requestedStartDate,
                        ),
                        if (request.applicantEmail != null)
                          _InfoRow(
                            label: 'Email',
                            value: request.applicantEmail!,
                          ),
                        if (request.message != null &&
                            request.message!.trim().isNotEmpty)
                          _InfoRow(
                            label: 'Message',
                            value: request.message!,
                          ),
                        if (request.status.toUpperCase() == 'PENDING') ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _reject(context, ref, request),
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: () => _approve(context, ref, request),
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                        if (request.status.toUpperCase() == 'APPROVED') ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: request.leaseExists
                                ? const Chip(
                                    avatar: Icon(
                                      Icons.verified_outlined,
                                      size: 18,
                                    ),
                                    label: Text('Lease Active'),
                                  )
                                : FilledButton.icon(
                                    onPressed: () =>
                                        _createLease(context, ref, request),
                                    icon: const Icon(
                                      Icons.description_outlined,
                                    ),
                                    label: const Text('Create Lease'),
                                  ),
                          ),
                        ],
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

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
