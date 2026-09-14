import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes.dart';
import 'theme.dart';
import '../features/auth/providers/auth_provider.dart';

class RentalPlatformApp extends ConsumerStatefulWidget {
  const RentalPlatformApp({super.key});

  @override
  ConsumerState<RentalPlatformApp> createState() =>
      _RentalPlatformAppState();
}

class _RentalPlatformAppState
    extends ConsumerState<RentalPlatformApp> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(authProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Rental Platform',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}