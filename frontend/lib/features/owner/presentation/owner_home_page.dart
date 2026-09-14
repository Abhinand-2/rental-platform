import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/leases/providers/lease_provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../leases/models/lease_model.dart';
import '../../leases/presentation/owner_leases_page.dart';
import '../../properties/models/property_model.dart';
import '../../owner/presentation/create_property_page.dart';
import '../../properties/providers/property_provider.dart';
import '../../rental_requests/models/rental_request_model.dart';
import '../../owner/presentation/owner_rental_requests_page.dart';
import '../../rental_requests/providers/rental_request_provider.dart';
import '../../rent/models/rent_charge_model.dart';
import '../../rent/presentation/owner_rent_page.dart';
import '../../rent/providers/rent_provider.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/theme.dart';

class OwnerHomePage extends ConsumerWidget {
  const OwnerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: LoadingState(),
      );
    }

    final propertiesAsync = ref.watch(
      ownerPropertiesProvider(user.id),
    );

    final requestsAsync = ref.watch(
      ownerRentalRequestsProvider,
    );

    final leasesAsync = ref.watch(
      ownerLeasesProvider,
    );

    final rentAsync = ref.watch(
      ownerRentChargesProvider,
    );

    void refreshDashboard() {
      ref.invalidate(ownerPropertiesProvider(user.id));
      ref.invalidate(ownerRentalRequestsProvider);
      ref.invalidate(ownerLeasesProvider);
      ref.invalidate(ownerRentChargesProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Rental Requests',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OwnerRentalRequestsPage(),
                ),
              );
            },
            icon: const Icon(Icons.assignment_outlined),
          ),
          IconButton(
            tooltip: 'Rent & Payments',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OwnerRentPage(),
                ),
              );
            },
            icon: const Icon(Icons.payments_outlined),
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
      body: RefreshIndicator(
        onRefresh: () async {
          refreshDashboard();

          await Future.wait([
            ref.read(ownerPropertiesProvider(user.id).future),
            ref.read(ownerRentalRequestsProvider.future),
            ref.read(ownerLeasesProvider.future),
            ref.read(ownerRentChargesProvider.future),
          ]);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(
                    firstName: user.firstName,
                  ),
                  const SizedBox(height: 28),
                  _DashboardContent(
                    propertiesAsync: propertiesAsync,
                    requestsAsync: requestsAsync,
                    leasesAsync: leasesAsync,
                    rentAsync: rentAsync,
                    onAddProperty: () async {
                      final created =
                          await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const CreatePropertyPage(),
                        ),
                      );

                      if (created == true) {
                        ref.invalidate(
                          ownerPropertiesProvider(user.id),
                        );
                      }
                    },
                    onViewRequests: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const OwnerRentalRequestsPage(),
                        ),
                      );
                    },
                    onViewLeases: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OwnerLeasesPage(),
                        ),
                      );
                    },
                    onViewRent: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OwnerRentPage(),
                        ),
                      );
                    },
                    onRetry: refreshDashboard,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created =
              await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const CreatePropertyPage(),
            ),
          );

          if (created == true) {
            ref.invalidate(ownerPropertiesProvider(user.id));
          }
        },
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('Add Property'),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String firstName;

  const _DashboardHeader({
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good to see you, $firstName',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Here is how your rental business is doing.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final AsyncValue<List<PropertyModel>> propertiesAsync;
  final AsyncValue<List<RentalRequestModel>> requestsAsync;
  final AsyncValue<List<LeaseModel>> leasesAsync;
  final AsyncValue<List<RentChargeModel>> rentAsync;

  final VoidCallback onAddProperty;
  final VoidCallback onViewRequests;
  final VoidCallback onViewLeases;
  final VoidCallback onViewRent;
  final VoidCallback onRetry;

  const _DashboardContent({
    required this.propertiesAsync,
    required this.requestsAsync,
    required this.leasesAsync,
    required this.rentAsync,
    required this.onAddProperty,
    required this.onViewRequests,
    required this.onViewLeases,
    required this.onViewRent,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final properties = propertiesAsync.valueOrNull ?? [];
    final requests = requestsAsync.valueOrNull ?? [];
    final leases = leasesAsync.valueOrNull ?? [];
    final rentCharges = rentAsync.valueOrNull ?? [];

    final hasAnyData =
        propertiesAsync.hasValue &&
        requestsAsync.hasValue &&
        leasesAsync.hasValue &&
        rentAsync.hasValue;

    if (!hasAnyData &&
        (propertiesAsync.hasError ||
            requestsAsync.hasError ||
            leasesAsync.hasError ||
            rentAsync.hasError)) {
      return ErrorState(
        message: 'Unable to load your dashboard data.',
        onRetry: onRetry,
      );
    }

    if (!hasAnyData) {
      return const LoadingState(
        message: 'Loading your dashboard...',
      );
    }

    final propertyStats = _PropertyStats.from(properties);
    final rentStats = _RentStats.from(rentCharges);

    final pendingRequests = requests
        .where(
          (request) => request.status.toUpperCase() == 'PENDING',
        )
        .toList();

    final activeLeases = leases
        .where(
          (lease) => lease.status.toUpperCase() == 'ACTIVE',
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveGrid(
          spacing: 14,
          children: [
            StatCard(
              title: 'Properties',
              value: '${properties.length}',
              icon: Icons.home_work_outlined,
              iconColor: AppTheme.primary,
            ),
            StatCard(
              title: 'Occupied',
              value: '${propertyStats.occupied}',
              subtitle:
                  '${propertyStats.occupancyPercentage.toStringAsFixed(0)}% occupancy',
              icon: Icons.people_alt_outlined,
              iconColor: AppTheme.accent,
            ),
            StatCard(
              title: 'Expected Rent',
              value: _formatCurrency(rentStats.expected),
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppTheme.info,
            ),
            StatCard(
              title: 'Collected',
              value: _formatCurrency(rentStats.collected),
              subtitle: rentStats.expected > 0
                  ? '${rentStats.collectionPercentage.toStringAsFixed(0)}% collected'
                  : null,
              icon: Icons.payments_outlined,
              iconColor: AppTheme.success,
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _SectionTitle(
          title: 'Rental overview',
          subtitle:
              'Your properties and rent performance at a glance.',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _OccupancyCard(
                      properties: properties,
                      stats: propertyStats,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RentSummaryCard(
                      stats: rentStats,
                      onViewAll: onViewRent,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _OccupancyCard(
                  properties: properties,
                  stats: propertyStats,
                ),
                const SizedBox(height: 16),
                _RentSummaryCard(
                  stats: rentStats,
                  onViewAll: onViewRent,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        _SectionTitle(
          title: 'Rent collection',
          subtitle: 'Track paid, pending and overdue charges.',
          trailing: TextButton(
            onPressed: onViewRent,
            child: const Text('View all'),
          ),
        ),
        const SizedBox(height: 14),
        _RentCollectionCard(
          stats: rentStats,
          charges: rentCharges,
          onViewAll: onViewRent,
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _RequestsCard(
                      requests: pendingRequests,
                      onViewAll: onViewRequests,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _LeasesCard(
                      leases: activeLeases,
                      onViewAll: onViewLeases,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _RequestsCard(
                  requests: pendingRequests,
                  onViewAll: onViewRequests,
                ),
                const SizedBox(height: 16),
                _LeasesCard(
                  leases: activeLeases,
                  onViewAll: onViewLeases,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        _QuickActionsCard(
          onAddProperty: onAddProperty,
          onViewRequests: onViewRequests,
          onViewLeases: onViewLeases,
          onViewRent: onViewRent,
        ),
      ],
    );
  }
}

class _PropertyStats {
  final int occupied;
  final int available;
  final int other;

  const _PropertyStats({
    required this.occupied,
    required this.available,
    required this.other,
  });

  int get total => occupied + available + other;

  double get occupancyPercentage {
    if (total == 0) {
      return 0;
    }

    return (occupied / total) * 100;
  }

  factory _PropertyStats.from(
    List<PropertyModel> properties,
  ) {
    int occupied = 0;
    int available = 0;
    int other = 0;

    for (final property in properties) {
      final status = property.status.toUpperCase();

      if (status == 'RENTED') {
        occupied++;
      } else if (status == 'PUBLISHED' ||
          status == 'APPROVED') {
        available++;
      } else {
        other++;
      }
    }

    return _PropertyStats(
      occupied: occupied,
      available: available,
      other: other,
    );
  }
}

class _RentStats {
  final double expected;
  final double collected;
  final double pending;
  final double overdue;

  const _RentStats({
    required this.expected,
    required this.collected,
    required this.pending,
    required this.overdue,
  });

  double get collectionPercentage {
    if (expected <= 0) {
      return 0;
    }

    return (collected / expected) * 100;
  }

  factory _RentStats.from(
    List<RentChargeModel> charges,
  ) {
    double expected = 0;
    double collected = 0;
    double pending = 0;
    double overdue = 0;

    for (final charge in charges) {
      final amount = charge.amount;
      final status = charge.status.toUpperCase();

      if (status != 'CANCELLED') {
        expected += amount;
      }

      switch (status) {
        case 'PAID':
          collected += amount;
          break;
        case 'PENDING':
          pending += amount;
          break;
        case 'OVERDUE':
          overdue += amount;
          break;
      }
    }

    return _RentStats(
      expected: expected,
      collected: collected,
      pending: pending,
      overdue: overdue,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  final List<PropertyModel> properties;
  final _PropertyStats stats;

  const _OccupancyCard({
    required this.properties,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Property occupancy',
            subtitle: 'Current property status',
          ),
          const SizedBox(height: 24),
          if (properties.isEmpty)
            const EmptyState(
              icon: Icons.home_work_outlined,
              title: 'No properties yet',
              message:
                  'Add your first property to start tracking occupancy.',
            )
          else
            _OccupancyDistribution(stats: stats),
        ],
      ),
    );
  }
}

class _OccupancyDistribution extends StatelessWidget {
  final _PropertyStats stats;

  const _OccupancyDistribution({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SegmentedBar(
          total: stats.total,
          segments: [
            _DistributionItem(
              label: 'Occupied',
              value: stats.occupied,
              color: AppTheme.success,
            ),
            _DistributionItem(
              label: 'Available',
              value: stats.available,
              color: AppTheme.info,
            ),
            if (stats.other > 0)
              _DistributionItem(
                label: 'Other',
                value: stats.other,
                color: AppTheme.warning,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _LegendItem(
              label: 'Occupied',
              value: stats.occupied,
              color: AppTheme.success,
            ),
            _LegendItem(
              label: 'Available',
              value: stats.available,
              color: AppTheme.info,
            ),
            if (stats.other > 0)
              _LegendItem(
                label: 'Other',
                value: stats.other,
                color: AppTheme.warning,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${stats.occupancyPercentage.toStringAsFixed(0)}% occupied',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _RentSummaryCard extends StatelessWidget {
  final _RentStats stats;
  final VoidCallback onViewAll;

  const _RentSummaryCard({
    required this.stats,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Rent performance',
            subtitle: 'Current charge status',
            trailing: IconButton(
              tooltip: 'View rent',
              onPressed: onViewAll,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
          const SizedBox(height: 24),
          _AmountRow(
            label: 'Expected',
            amount: stats.expected,
            icon: Icons.account_balance_wallet_outlined,
            color: AppTheme.info,
          ),
          const SizedBox(height: 16),
          _AmountRow(
            label: 'Collected',
            amount: stats.collected,
            icon: Icons.check_circle_outline,
            color: AppTheme.success,
          ),
          const SizedBox(height: 16),
          _AmountRow(
            label: 'Pending',
            amount: stats.pending,
            icon: Icons.schedule_outlined,
            color: AppTheme.warning,
          ),
          const SizedBox(height: 16),
          _AmountRow(
            label: 'Overdue',
            amount: stats.overdue,
            icon: Icons.warning_amber_rounded,
            color: AppTheme.danger,
          ),
        ],
      ),
    );
  }
}

class _RentCollectionCard extends StatelessWidget {
  final _RentStats stats;
  final List<RentChargeModel> charges;
  final VoidCallback onViewAll;

  const _RentCollectionCard({
    required this.stats,
    required this.charges,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats.expected;

    final paidRatio =
        total > 0 ? stats.collected / total : 0.0;
    final pendingRatio =
        total > 0 ? stats.pending / total : 0.0;
    final overdueRatio =
        total > 0 ? stats.overdue / total : 0.0;

    final recentCharges = [...charges]
      ..sort(
        (a, b) => b.dueDate.compareTo(a.dueDate),
      );

    final visibleCharges = recentCharges.take(5).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Collection status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SegmentedDoubleBar(
            total: total,
            segments: [
              _DoubleDistributionItem(
                label: 'Paid',
                value: stats.collected,
                ratio: paidRatio,
                color: AppTheme.success,
              ),
              _DoubleDistributionItem(
                label: 'Pending',
                value: stats.pending,
                ratio: pendingRatio,
                color: AppTheme.warning,
              ),
              _DoubleDistributionItem(
                label: 'Overdue',
                value: stats.overdue,
                ratio: overdueRatio,
                color: AppTheme.danger,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _LegendAmountItem(
                label: 'Paid',
                amount: stats.collected,
                color: AppTheme.success,
              ),
              _LegendAmountItem(
                label: 'Pending',
                amount: stats.pending,
                color: AppTheme.warning,
              ),
              _LegendAmountItem(
                label: 'Overdue',
                amount: stats.overdue,
                color: AppTheme.danger,
              ),
            ],
          ),
          if (visibleCharges.isNotEmpty) ...[
            const SizedBox(height: 24),
            const AppDivider(),
            const SizedBox(height: 4),
            ...visibleCharges.map(
              (charge) => _RentChargeRow(charge: charge),
            ),
          ] else ...[
            const SizedBox(height: 20),
            const Text('No rent charges available yet.'),
          ],
        ],
      ),
    );
  }
}

class _SegmentedDoubleBar extends StatelessWidget {
  final double total;
  final List<_DoubleDistributionItem> segments;

  const _SegmentedDoubleBar({
    required this.total,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 0) {
      return Container(
        height: 14,
        decoration: BoxDecoration(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 14,
        child: Row(
          children: [
            for (final segment in segments)
              if (segment.value > 0)
                Expanded(
                  flex: (segment.ratio * 1000)
                      .round()
                      .clamp(1, 1000),
                  child: Container(
                    color: segment.color,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _DoubleDistributionItem {
  final String label;
  final double value;
  final double ratio;
  final Color color;

  const _DoubleDistributionItem({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
  });
}

class _LegendAmountItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _LegendAmountItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 5),
        Text(
          _formatCurrency(amount),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _DistributionItem {
  final String label;
  final int value;
  final Color color;

  const _DistributionItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _SegmentedBar extends StatelessWidget {
  final int total;
  final List<_DistributionItem> segments;

  const _SegmentedBar({
    required this.total,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 0) {
      return Container(
        height: 22,
        decoration: BoxDecoration(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            for (final segment in segments)
              if (segment.value > 0)
                Expanded(
                  flex: segment.value,
                  child: Container(
                    color: segment.color,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _RentChargeRow extends StatelessWidget {
  final RentChargeModel charge;

  const _RentChargeRow({
    required this.charge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 20,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  charge.monthLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Due ${charge.dueDate}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(charge.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 5),
              StatusBadge(status: charge.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestsCard extends StatelessWidget {
  final List<RentalRequestModel> requests;
  final VoidCallback onViewAll;

  const _RequestsCard({
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Rental requests',
            subtitle: 'Requests waiting for your action',
            trailing: TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 18),
          if (requests.isEmpty)
            const _SmallEmptyState(
              icon: Icons.inbox_outlined,
              message: 'No pending rental requests.',
            )
          else
            ...requests.take(4).map(
              (request) => _RequestRow(request: request),
            ),
        ],
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final RentalRequestModel request;

  const _RequestRow({
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: AppTheme.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.displayApplicantName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  request.applicantEmail ??
                      request.displayApplicantName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          StatusBadge(status: request.status),
        ],
      ),
    );
  }
}

class _LeasesCard extends StatelessWidget {
  final List<LeaseModel> leases;
  final VoidCallback onViewAll;

  const _LeasesCard({
    required this.leases,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Active leases',
            subtitle: 'Currently occupied properties',
            trailing: TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 18),
          if (leases.isEmpty)
            const _SmallEmptyState(
              icon: Icons.description_outlined,
              message: 'No active leases.',
            )
          else
            ...leases.take(4).map(
              (lease) => _LeaseRow(lease: lease),
            ),
        ],
      ),
    );
  }
}

class _LeaseRow extends StatelessWidget {
  final LeaseModel lease;

  const _LeaseRow({
    required this.lease,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.home_outlined,
              size: 20,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lease.displayPropertyTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  lease.displayPropertyTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(lease.monthlyRent),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final VoidCallback onAddProperty;
  final VoidCallback onViewRequests;
  final VoidCallback onViewLeases;
  final VoidCallback onViewRent;

  const _QuickActionsCard({
    required this.onAddProperty,
    required this.onViewRequests,
    required this.onViewLeases,
    required this.onViewRent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Quick actions',
            subtitle:
                'Jump straight to the tasks you use most.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 650;

              final actions = [
                _QuickAction(
                  icon: Icons.add_home_work_outlined,
                  title: 'Add property',
                  onTap: onAddProperty,
                ),
                _QuickAction(
                  icon: Icons.assignment_outlined,
                  title: 'Rental requests',
                  onTap: onViewRequests,
                ),
                _QuickAction(
                  icon: Icons.description_outlined,
                  title: 'Leases',
                  onTap: onViewLeases,
                ),
                _QuickAction(
                  icon: Icons.payments_outlined,
                  title: 'Rent & payments',
                  onTap: onViewRent,
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      Expanded(child: actions[i]),
                      if (i != actions.length - 1)
                        const SizedBox(width: 10),
                    ],
                  ],
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actions.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, index) {
                  return actions[index];
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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

class _AmountRow extends StatelessWidget {
  final String label;
  final double? amount;
  final String? value;
  final IconData? icon;
  final Color? color;
  final Color? valueColor;

  const _AmountRow({
    required this.label,
    this.amount,
    this.value,
    this.icon,
    this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primary;

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        Text(
          value ?? _formatCurrency(amount ?? 0),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 5),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _SmallEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _SmallEmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) {
  if (amount >= 10000000) {
    return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
  }

  if (amount >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)}L';
  }

  if (amount >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  }

  return '₹${amount.toStringAsFixed(0)}';
}