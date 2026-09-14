
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/property_model.dart';
import '../providers/property_provider.dart';
import '../../rental_requests/presentation/request_to_rent_page.dart';

class PropertyDetailsPage extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailsPage({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final propertyAsync =
        ref.watch(propertyDetailsProvider(propertyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          IconButton(
            tooltip: 'Save property',
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: propertyAsync.when(
        loading: () => const LoadingState(
          message: 'Loading property...',
        ),
        error: (error, stackTrace) => ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(
              propertyDetailsProvider(propertyId),
            );
          },
        ),
        data: (property) {
          return _PropertyDetailsContent(
            property: property,
          );
        },
      ),
    );
  }
}

class _PropertyDetailsContent extends StatelessWidget {
  final PropertyModel property;

  const _PropertyDetailsContent({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 32 : 20,
            20,
            isDesktop ? 32 : 20,
            isDesktop ? 40 : 120,
          ),
          child: ResponsiveContent(
            maxWidth: 1400,
            child: isDesktop
                ? _buildDesktopLayout(context)
                : _buildMobileLayout(context),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PropertyGallery(
          property: property,
        ),
        const SizedBox(height: 24),
        _PropertyHeader(
          property: property,
        ),
        const SizedBox(height: 24),
        _PropertyHighlights(
          property: property,
        ),
        const SizedBox(height: 24),
        _RentCard(
          property: property,
        ),
        const SizedBox(height: 24),
        _DescriptionSection(
          property: property,
        ),
        const SizedBox(height: 24),
        _PropertyInformation(
          property: property,
        ),
        const SizedBox(height: 24),
        _AmenitiesSection(),
        const SizedBox(height: 24),
        _RequestCard(
          property: property,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PropertyGallery(
          property: property,
        ),
        const SizedBox(height: 28),
        _PropertyHeader(
          property: property,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  _PropertyHighlights(
                    property: property,
                  ),
                  const SizedBox(height: 20),
                  _DescriptionSection(
                    property: property,
                  ),
                  const SizedBox(height: 20),
                  _PropertyInformation(
                    property: property,
                  ),
                  const SizedBox(height: 20),
                  const _AmenitiesSection(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _RentCard(
                    property: property,
                  ),
                  const SizedBox(height: 20),
                  _RequestCard(
                    property: property,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PropertyGallery extends StatelessWidget {
  final PropertyModel property;

  const _PropertyGallery({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppTheme.cardRadius,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: Container(
          color: AppTheme.accentLight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Center(
                child: Icon(
                  Icons.home_work_outlined,
                  size: 72,
                  color: AppTheme.accent,
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: StatusBadge(
                  status: 'PUBLISHED',
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: Material(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {},
                    borderRadius:
                        BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'View photos',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyHeader extends StatelessWidget {
  final PropertyModel property;

  const _PropertyHeader({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 19,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _locationText(property),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatusBadge(
          status: _formatPropertyType(
            property.type,
          ),
        ),
      ],
    );
  }
}

class _PropertyHighlights extends StatelessWidget {
  final PropertyModel property;

  const _PropertyHighlights({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 500;

          final items = [
            _HighlightItem(
              icon: Icons.bed_outlined,
              label: 'Bedrooms',
              value:
                  _nullableNumber(property.bedrooms),
            ),
            _HighlightItem(
              icon: Icons.bathtub_outlined,
              label: 'Bathrooms',
              value:
                  _nullableNumber(property.bathrooms),
            ),
            _HighlightItem(
              icon: Icons.square_foot_outlined,
              label: 'Area',
              value: property.areaSqFt == null
                  ? '—'
                  : '${property.areaSqFt} sq ft',
            ),
            _HighlightItem(
              icon: Icons.home_work_outlined,
              label: 'Type',
              value: _formatPropertyType(
                property.type,
              ),
            ),
          ];

          if (compact) {
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: items,
            );
          }

          return Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: items,
          );
        },
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HighlightItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.accent,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color:
                        AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RentCard extends StatelessWidget {
  final PropertyModel property;

  const _RentCard({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly rent',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _currency(property.monthlyRent),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppTheme.primary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'per month',
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
          const SizedBox(height: 20),
          const AppDivider(),
          const SizedBox(height: 16),
          _MoneyRow(
            label: 'Security deposit',
            amount:
                property.securityDeposit,
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double? amount;

  const _MoneyRow({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppTheme.textSecondary,
                ),
          ),
        ),
        Text(
          amount == null
              ? 'Not specified'
              : _currency(amount!),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final PropertyModel property;

  const _DescriptionSection({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final description =
        property.description?.trim();

    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'About this property',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            description == null ||
                    description.isEmpty
                ? 'No description provided.'
                : description,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  color:
                      AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _PropertyInformation extends StatelessWidget {
  final PropertyModel property;

  const _PropertyInformation({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Property information',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Property type',
            value: _formatPropertyType(
              property.type,
            ),
          ),
          const AppDivider(),
          _InfoRow(
            label: 'Address',
            value: property.addressLine,
          ),
          const AppDivider(),
          _InfoRow(
            label: 'City',
            value: property.city,
          ),
          const AppDivider(),
          _InfoRow(
            label: 'State',
            value: property.state,
          ),
          const AppDivider(),
          _InfoRow(
            label: 'Postal code',
            value: property.postalCode,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color:
                        AppTheme.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection();

  @override
  Widget build(BuildContext context) {
    // Amenities will be connected to the
    // existing amenities provider next.
    const amenities = [
      'Parking',
      'Security',
      'Water supply',
      'Power backup',
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: amenities
                .map(
                  (amenity) => Chip(
                    avatar: const Icon(
                      Icons.check_rounded,
                      size: 17,
                    ),
                    label: Text(amenity),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final PropertyModel property;

  const _RequestCard({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Interested in this property?',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a rental request to the owner.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RequestToRentPage(
                      propertyId: property.id,
                      propertyTitle: property.title,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.send_rounded,
              ),
              label: const Text(
                'Request to Rent',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _locationText(PropertyModel property) {
  final parts = [
    property.addressLine,
    property.city,
    property.state,
    property.postalCode,
  ].where(
    (value) => value.trim().isNotEmpty,
  );

  return parts.join(', ');
}

String _formatPropertyType(String type) {
  return type
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}'
                '${word.substring(1)}',
      )
      .join(' ');
}

String _nullableNumber(int? value) {
  return value == null ? '—' : value.toString();
}

String _currency(double amount) {
  return '₹${amount.toStringAsFixed(0)}';
}

