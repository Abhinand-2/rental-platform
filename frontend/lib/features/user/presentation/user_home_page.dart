import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_ui.dart';
import '../../auth/providers/auth_provider.dart';
import '../../properties/models/property_model.dart';
import '../../properties/presentation/property_details_page.dart';
import '../../properties/providers/property_provider.dart';
import '../../rental_requests/presentation/my_rental_requests_page.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';

  final List<String> _propertyTypes = const [
    'All',
    'Apartment',
    'House',
    'Villa',
    'Studio',
    'PG',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PropertyModel> _filtered(List<PropertyModel> properties) {
    final query = _searchController.text.trim().toLowerCase();

    return properties.where((property) {
      final typeMatches = _selectedType == 'All' ||
          property.type.toUpperCase() == _selectedType.toUpperCase();

      if (!typeMatches) return false;
      if (query.isEmpty) return true;

      final searchable = [
        property.title,
        property.description ?? '',
        property.addressLine,
        property.city,
        property.state,
        property.postalCode,
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final propertiesAsync = ref.watch(publishedPropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Home'),
        actions: [
          IconButton(
            tooltip: 'Rental requests',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyRentalRequestsPage(),
                ),
              );
            },
            icon: const Icon(Icons.assignment_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: propertiesAsync.when(
        loading: () => const LoadingState(message: 'Loading available properties...'),
        error: (error, stackTrace) => ErrorState(
          message: 'Unable to load properties.',
          onRetry: () => ref.invalidate(publishedPropertiesProvider),
        ),
        data: (properties) {
          final filtered = _filtered(properties);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(publishedPropertiesProvider);
              await ref.read(publishedPropertiesProvider.future);
            },
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1000;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                      vertical: 20,
                    ),
                    child: ResponsiveContent(
                      maxWidth: 1400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Welcome(
                            firstName: user?.firstName ?? 'there',
                          ),
                          const SizedBox(height: 24),
                          AppCard(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search by city, area or property',
                                prefixIcon: Icon(Icons.search_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppSectionHeader(
                            title: 'Browse by type',
                            trailing: Text(
                              '${filtered.length} available',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 42,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _propertyTypes.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final type = _propertyTypes[index];
                                return ChoiceChip(
                                  label: Text(type),
                                  selected: _selectedType == type,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedType = type;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (filtered.isEmpty)
                            const EmptyState(
                              icon: Icons.home_work_outlined,
                              title: 'No properties found',
                              message:
                                  'Try another search or property type.',
                            )
                          else
                            _PropertyGrid(properties: filtered),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  final String firstName;

  const _Welcome({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $firstName',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Find a home that fits your needs.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _PropertyGrid extends StatelessWidget {
  final List<PropertyModel> properties;

  const _PropertyGrid({required this.properties});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: properties.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: columns == 1 ? 0.95 : 0.88,
          ),
          itemBuilder: (context, index) {
            final property = properties[index];

            return AppCard(
              padding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailsPage(
                      propertyId: property.id,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.cardRadius),
                      ),
                      child: Container(
                        color: AppTheme.accentLight,
                        child: const Icon(
                          Icons.home_work_outlined,
                          size: 54,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${property.city}, ${property.state}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹${property.monthlyRent.toStringAsFixed(0)} / month',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          children: [
                            if (property.bedrooms != null)
                              Text('${property.bedrooms} Beds'),
                            if (property.bathrooms != null)
                              Text('${property.bathrooms} Baths'),
                            if (property.areaSqFt != null)
                              Text(
                                '${property.areaSqFt!.toStringAsFixed(0)} sq ft',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
