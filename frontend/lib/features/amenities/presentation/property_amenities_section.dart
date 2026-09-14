import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/amenity_provider.dart';

class PropertyAmenitiesSection extends ConsumerWidget {
  final String propertyId;

  const PropertyAmenitiesSection({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amenitiesAsync =
        ref.watch(propertyAmenitiesProvider(propertyId));

    return amenitiesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) {
        return const Text(
          'Unable to load amenities',
        );
      },
      data: (amenities) {
        if (amenities.isEmpty) {
          return const Text(
            'No amenities listed',
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            return Chip(
              avatar: const Icon(
                Icons.check_circle_outline,
                size: 18,
              ),
              label: Text(amenity.name),
            );
          }).toList(),
        );
      },
    );
  }
}