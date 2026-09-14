import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/owner/presentation/owner_home_page.dart';
import '../features/user/presentation/user_home_page.dart';
import '../features/admin/presentation/admin_home_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

   redirect: (context, state) {
  final isLoggedIn = authState.isLoggedIn;
  final user = authState.user;

  final isLoginRoute = state.matchedLocation == '/login';

  if (authState.isLoading) {
    return null;
  }

  if (!isLoggedIn || user == null) {
    return isLoginRoute ? null : '/login';
  }

  if (isLoginRoute) {
    switch (user.role) {
      case 'USER':
        return '/user';

      case 'OWNER':
        return '/owner';

      case 'ADMIN':
        return '/admin';

      default:
        return '/login';
    }
  }

  if (user.role == 'USER' &&
      !state.matchedLocation.startsWith('/user')) {
    return '/user';
  }

  if (user.role == 'OWNER' &&
      !state.matchedLocation.startsWith('/owner')) {
    return '/owner';
  }

  if (user.role == 'ADMIN' &&
      !state.matchedLocation.startsWith('/admin')) {
    return '/admin';
  }

  return null;
},

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      GoRoute(
        path: '/user',
        builder: (context, state) {
          return const UserHomePage();
        },
      ),

      GoRoute(
        path: '/owner',
        builder: (context, state) {
          return const OwnerHomePage();
        },
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) {
          return const AdminHomePage();
        },
      ),
    ],

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    },
  );
});