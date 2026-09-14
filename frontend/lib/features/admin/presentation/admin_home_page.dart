import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_ui.dart';

import '../../auth/providers/auth_provider.dart';

import '../models/admin_dashboard_model.dart';
import '../providers/admin_provider.dart';

import 'admin_leases_page.dart';
import 'admin_properties_page.dart';
import 'admin_rental_requests_page.dart';
import 'admin_users_page.dart';
import 'admin_rent_page.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final dashboardAsync = ref.watch(adminDashboardProvider);

    Future<void> refresh() async {
      ref.invalidate(adminDashboardProvider);
      await ref.read(adminDashboardProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: refresh,
            icon: const Icon(Icons.refresh_rounded),
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
        onRefresh: refresh,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: ResponsiveContent(
              child: dashboardAsync.when(
                loading: () => const LoadingState(
                  message: 'Loading platform statistics...',
                ),
                error: (error, stackTrace) => ErrorState(
                  message: 'Unable to load the admin dashboard.',
                  onRetry: refresh,
                ),
                data: (dashboard) => _DashboardContent(
                  dashboard: dashboard,
                  firstName: user?.firstName ?? 'Admin',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final AdminDashboardModel dashboard;
  final String firstName;

  const _DashboardContent({
    required this.dashboard,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHeader(firstName: firstName),
        const SizedBox(height: 28),
        _OverviewStats(dashboard: dashboard),
        const SizedBox(height: 30),
        const _SectionTitle(
          title: 'Platform overview',
          subtitle: 'A snapshot of your rental platform.',
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
                    child: _PropertyOverviewCard(
                      dashboard: dashboard,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RentalOverviewCard(
                      dashboard: dashboard,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _PropertyOverviewCard(
                  dashboard: dashboard,
                ),
                const SizedBox(height: 16),
                _RentalOverviewCard(
                  dashboard: dashboard,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        _SectionTitle(
          title: 'Rent collection',
          subtitle: 'Monitor platform-wide rent activity.',
          trailing: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdminRentPage(),
                ),
              );
            },
            child: const Text('View rent'),
          ),
        ),
        const SizedBox(height: 14),
        _RentCollectionCard(
          dashboard: dashboard,
        ),
        const SizedBox(height: 30),
        const _SectionTitle(
          title: 'Management',
          subtitle: 'Quick access to platform operations.',
        ),
        const SizedBox(height: 14),
        const _ManagementGrid(),
      ],
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
          'Here is what is happening across your rental platform.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OverviewStats extends StatelessWidget {
  final AdminDashboardModel dashboard;

  const _OverviewStats({
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      spacing: 14,
      children: [
        StatCard(
          title: 'Total Users',
          value: '${dashboard.totalUsers}',
          icon: Icons.people_alt_outlined,
          iconColor: AppTheme.primary,
        ),
        StatCard(
          title: 'Properties',
          value: '${dashboard.totalProperties}',
          subtitle: '${dashboard.publishedProperties} published',
          icon: Icons.home_work_outlined,
          iconColor: AppTheme.accent,
        ),
        StatCard(
          title: 'Active Leases',
          value: '${dashboard.activeLeases}',
          icon: Icons.description_outlined,
          iconColor: AppTheme.info,
        ),
        StatCard(
          title: 'Pending Requests',
          value: '${dashboard.pendingRentalRequests}',
          subtitle: '${dashboard.totalRentalRequests} total requests',
          icon: Icons.assignment_outlined,
          iconColor: AppTheme.warning,
        ),
      ],
    );
  }
}

class _PropertyOverviewCard extends StatelessWidget {
  final AdminDashboardModel dashboard;

  const _PropertyOverviewCard({
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final total = dashboard.totalProperties;
    final published = dashboard.publishedProperties;
    final pending = dashboard.pendingProperties;

    final remaining = total - published - pending;
    final other = remaining < 0 ? 0 : remaining;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Property status',
            subtitle: 'Current listing distribution',
            icon: Icons.home_work_outlined,
          ),
          const SizedBox(height: 24),
          if (total == 0)
            const SizedBox(
              height: 180,
              child: _SmallEmptyState(
                icon: Icons.home_work_outlined,
                message: 'No properties yet',
              ),
            )
          else
            _StatusDistribution(
              total: total,
              items: [
                _DistributionItem(
                  label: 'Published',
                  value: published,
                  color: AppTheme.success,
                ),
                _DistributionItem(
                  label: 'Pending',
                  value: pending,
                  color: AppTheme.warning,
                ),
                if (other > 0)
                  _DistributionItem(
                    label: 'Other',
                    value: other,
                    color: AppTheme.textSecondary,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RentalOverviewCard extends StatelessWidget {
  final AdminDashboardModel dashboard;

  const _RentalOverviewCard({
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final total = dashboard.totalRentalRequests;
    final pending = dashboard.pendingRentalRequests;
    final processed = total - pending;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Rental activity',
            subtitle: 'Request and lease activity',
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Requests',
                  value: '$total',
                  icon: Icons.assignment_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBlock(
                  label: 'Pending',
                  value: '$pending',
                  icon: Icons.hourglass_empty_rounded,
                  iconColor: AppTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const AppDivider(),
          const SizedBox(height: 20),
          _AmountRow(
            label: 'Active leases',
            value: '${dashboard.activeLeases}',
          ),
          const SizedBox(height: 12),
          _AmountRow(
            label: 'Processed requests',
            value: '${processed < 0 ? 0 : processed}',
          ),
        ],
      ),
    );
  }
}

class _RentCollectionCard extends StatelessWidget {
  final AdminDashboardModel dashboard;

  const _RentCollectionCard({
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final total = dashboard.totalRentAmount;
    final paid = dashboard.paidRentAmount;
    final overdue = dashboard.overdueRentAmount;

    final collectionPercentage =
        total > 0 ? (paid / total * 100).clamp(0, 100) : 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 650;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _CollectionMainMetric(
                        amount: paid,
                        percentage: collectionPercentage.toDouble(),
                      ),
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      width: 300,
                      child: _CollectionChart(
                        paidCharges: dashboard.paidRentCharges,
                        overdueCharges: dashboard.overdueRentCharges,
                        totalCharges: dashboard.totalRentCharges,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _CollectionMainMetric(
                    amount: paid,
                    percentage: collectionPercentage.toDouble(),
                  ),
                  const SizedBox(height: 28),
                  _CollectionChart(
                    paidCharges: dashboard.paidRentCharges,
                    overdueCharges: dashboard.overdueRentCharges,
                    totalCharges: dashboard.totalRentCharges,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const AppDivider(),
          const SizedBox(height: 20),
          Wrap(
            spacing: 30,
            runSpacing: 16,
            children: [
              _AmountRow(
                label: 'Total rent',
                value: _formatCurrency(total),
              ),
              _AmountRow(
                label: 'Paid',
                value: _formatCurrency(paid),
                valueColor: AppTheme.success,
              ),
              _AmountRow(
                label: 'Overdue',
                value: _formatCurrency(overdue),
                valueColor: AppTheme.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollectionMainMetric extends StatelessWidget {
  final double amount;
  final double percentage;

  const _CollectionMainMetric({
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collected rent',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatCurrency(amount),
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(0)}% collection rate',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: AppTheme.success.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }
}

class _CollectionChart extends StatelessWidget {
  final int paidCharges;
  final int overdueCharges;
  final int totalCharges;

  const _CollectionChart({
    required this.paidCharges,
    required this.overdueCharges,
    required this.totalCharges,
  });

  @override
  Widget build(BuildContext context) {
    final other = totalCharges - paidCharges - overdueCharges;

    if (totalCharges == 0) {
      return const _SmallEmptyState(
        icon: Icons.payments_outlined,
        message: 'No rent charges yet',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charge status',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 14),
        _SegmentedBar(
          total: totalCharges,
          segments: [
            _DistributionItem(
              label: 'Paid',
              value: paidCharges,
              color: AppTheme.success,
            ),
            _DistributionItem(
              label: 'Overdue',
              value: overdueCharges,
              color: AppTheme.danger,
            ),
            if (other > 0)
              _DistributionItem(
                label: 'Other',
                value: other,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            _LegendItem(
              label: 'Paid',
              value: paidCharges,
              color: AppTheme.success,
            ),
            _LegendItem(
              label: 'Overdue',
              value: overdueCharges,
              color: AppTheme.danger,
            ),
            if (other > 0)
              _LegendItem(
                label: 'Other',
                value: other,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusDistribution extends StatelessWidget {
  final int total;
  final List<_DistributionItem> items;

  const _StatusDistribution({
    required this.total,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SegmentedBar(
          total: total,
          segments: items,
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            for (final item in items)
              _LegendItem(
                label: item.label,
                value: item.value,
                color: item.color,
              ),
          ],
        ),
      ],
    );
  }
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

    final validSegments =
        segments.where((segment) => segment.value > 0).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            for (final segment in validSegments)
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

class _ManagementGrid extends StatelessWidget {
  const _ManagementGrid();

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      minItemWidth: 220,
      spacing: 14,
      children: [
        _ManagementCard(
          icon: Icons.home_work_outlined,
          title: 'Properties',
          subtitle: 'Review and manage property listings.',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminPropertiesPage(),
              ),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.people_outline,
          title: 'Users',
          subtitle: 'View owners, users and administrators.',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminUsersPage(),
              ),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.assignment_outlined,
          title: 'Rental Requests',
          subtitle: 'Review platform-wide rental requests.',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminRentalRequestsPage(),
              ),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.description_outlined,
          title: 'Leases',
          subtitle: 'Monitor active and historical leases.',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminLeasesPage(),
              ),
            );
          },
        ),
        _ManagementCard(
          icon: Icons.payments_outlined,
          title: 'Rent & Payments',
          subtitle: 'Manage charges and payment records.',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminRentPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _CardHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _MetricBlock({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: effectiveColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
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
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 34,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
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