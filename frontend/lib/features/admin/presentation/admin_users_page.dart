import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_user_model.dart';
import '../providers/admin_provider.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
  ) async {
    if (user.role == 'ADMIN') return;

    final newStatus = user.status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          newStatus == 'SUSPENDED'
              ? 'Suspend account'
              : 'Activate account',
        ),
        content: Text(
          newStatus == 'SUSPENDED'
              ? 'Suspend ${user.fullName}\'s account?'
              : 'Activate ${user.fullName}\'s account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(newStatus == 'SUSPENDED' ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(adminRepositoryProvider).updateUserStatus(
            user.id,
            newStatus,
          );

      ref.invalidate(adminUsersProvider);
      ref.invalidate(adminDashboardProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.fullName} is now ${newStatus.toLowerCase()}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
        data: (users) {
          if (users.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminUsersProvider);
                await ref.read(adminUsersProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No users found.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminUsersProvider);
              await ref.read(adminUsersProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      child: Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${user.email}\n${user.role} • ${user.status}',
                      ),
                    ),
                    trailing: user.role == 'ADMIN'
                        ? const Icon(Icons.admin_panel_settings_outlined)
                        : PopupMenuButton<String>(
                            onSelected: (_) =>
                                _changeStatus(context, ref, user),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'status',
                                child: Text(
                                  user.status == 'ACTIVE'
                                      ? 'Suspend account'
                                      : 'Activate account',
                                ),
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

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onRetry,
        child: const Text('Retry'),
      ),
    );
  }
}
