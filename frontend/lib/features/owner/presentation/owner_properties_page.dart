
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../properties/models/property_model.dart';
import '../../properties/providers/property_provider.dart';
import 'edit_property_page.dart';

class OwnerPropertiesPage extends ConsumerWidget {
  const OwnerPropertiesPage({
    super.key,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'PUBLISHED':
        return Colors.green;
      case 'APPROVED':
        return Colors.blue;
      case 'PENDING_APPROVAL':
        return Colors.orange;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Center(
        child: Text('User information unavailable'),
      );
    }

    final propertiesAsync =
        ref.watch(ownerPropertiesProvider(user.id));

    return propertiesAsync.when(
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
                'Failed to load your properties',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    ownerPropertiesProvider(user.id),
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
          return const _EmptyProperties();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              ownerPropertiesProvider(user.id),
            );

            await ref.read(
              ownerPropertiesProvider(user.id).future,
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              return _OwnerPropertyCard(
                property: properties[index],
                statusColor:
                    _statusColor(properties[index].status),
              );
            },
          ),
        );
      },
    );
  }
}

class _OwnerPropertyCard extends ConsumerWidget {
  final PropertyModel property;
  final Color statusColor;

  const _OwnerPropertyCard({
    required this.property,
    required this.statusColor,
  });

  Future<void> _publishProperty(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Publish Property'),
          content: const Text(
            'Are you sure you want to publish this property? '
            'It will become visible to users.',
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
              child: const Text('Publish'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final repository =
          ref.read(propertyRepositoryProvider);

      await repository.publishProperty(property.id);

      ref.invalidate(
        ownerPropertiesProvider(property.ownerId),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Property published successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to publish property: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                        .titleLarge
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
                    property.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              property.type,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 4),

            Text(
              '${property.addressLine}, ${property.city}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${property.monthlyRent.toStringAsFixed(0)}/month',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (property.bedrooms != null ||
                property.bathrooms != null ||
                property.areaSqFt != null)
              Wrap(
                spacing: 16,
                runSpacing: 8,
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
                      '${property.areaSqFt!.toStringAsFixed(0)} sq.ft',
                    ),
                ],
              ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                // Publish button is shown only
                // after admin approval.
                if (property.status == 'APPROVED')
                  OutlinedButton.icon(
                    onPressed: () {
                      _publishProperty(
                        context,
                        ref,
                      );
                    },
                    icon: const Icon(
                      Icons.publish,
                    ),
                    label: const Text('Publish'),
                  ),

                if (property.status == 'APPROVED')
                  const SizedBox(width: 8),

                OutlinedButton.icon(
                  onPressed: () async {
                    final updated =
                        await Navigator.of(context)
                            .push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            EditPropertyPage(
                          property: property,
                        ),
                      ),
                    );

                    if (updated == true) {
                      ref.invalidate(
                        ownerPropertiesProvider(
                          property.ownerId,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProperties extends StatelessWidget {
  const _EmptyProperties();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No properties yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first property to start managing rentals.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
