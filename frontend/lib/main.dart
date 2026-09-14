import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RentalPlatformApp(),
    ),
  );
}