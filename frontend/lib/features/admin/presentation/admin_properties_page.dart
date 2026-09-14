import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_provider.dart';

class AdminPropertiesPage extends ConsumerWidget {
  const AdminPropertiesPage({super.key});

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    String propertyId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Property'),
          content: const Text(
            'Are you sure you want to approve this property?',
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
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(adminRepositoryProvider)
          .approveProperty(propertyId);

      ref.invalidate(adminPropertiesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Property approved successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to approve property: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    String propertyId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Property'),
          content: const Text(
            'Are you sure you want to reject this property?',
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
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(adminRepositoryProvider)
          .rejectProperty(propertyId);

      ref.invalidate(adminPropertiesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Property rejected.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to reject property: $e',
            ),
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING_APPROVAL':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'PUBLISHED':
        return Colors.blue;
      case 'REJECTED':
        return Colors.red;
      case 'RENTED':
        return Colors.purple;
      case 'INACTIVE':
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
    final propertiesAsync =
        ref.watch(adminPropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
      ),
      body: propertiesAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load properties',
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      adminPropertiesProvider,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (properties) {
          if (properties.isEmpty) {
            return const Center(
              child: Text(
                'No properties found.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                adminPropertiesProvider,
              );

              await ref.read(
                adminPropertiesProvider.future,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];

                final statusColor =
                    _statusColor(property.status);

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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                property.title,
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
                                color: statusColor
                                    .withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                property.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          '${property.type} • '
                          '${property.city}, '
                          '${property.state}',
                        ),

                        const SizedBox(height: 8),

                        Text(
                          property.addressLine,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '₹${property.monthlyRent.toStringAsFixed(0)} / month',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (property.bedrooms != null ||
                            property.bathrooms != null ||
                            property.areaSqFt != null)
                          Wrap(
                            spacing: 16,
                            children: [
                              if (property.bedrooms != null)
                                Text(
                                  '${property.bedrooms} beds',
                                ),
                              if (property.bathrooms != null)
                                Text(
                                  '${property.bathrooms} baths',
                                ),
                              if (property.areaSqFt != null)
                                Text(
                                  '${property.areaSqFt} sq.ft',
                                ),
                            ],
                          ),

                        const SizedBox(height: 8),

                        Text(
                          'Owner ID: ${property.ownerId}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),

                        if (property.status ==
                            'PENDING_APPROVAL') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _reject(
                                  context,
                                  ref,
                                  property.id,
                                ),
                                icon: const Icon(
                                  Icons.close,
                                ),
                                label:
                                    const Text('Reject'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: () =>
                                    _approve(
                                  context,
                                  ref,
                                  property.id,
                                ),
                                icon: const Icon(
                                  Icons.check,
                                ),
                                label:
                                    const Text('Approve'),
                              ),
                            ],
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