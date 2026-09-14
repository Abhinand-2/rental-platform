import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'property_details_page.dart';
import '../providers/property_provider.dart';
import 'widgets/property_card.dart';

class PublishedPropertiesPage extends ConsumerWidget {
  const PublishedPropertiesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync =
        ref.watch(publishedPropertiesProvider);

    return propertiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Unable to load properties',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(
                        publishedPropertiesProvider,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },

        data: (properties) {
          if (properties.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  publishedPropertiesProvider,
                );
              },
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'No properties are currently available.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                publishedPropertiesProvider,
              );

              await ref.read(
                publishedPropertiesProvider.future,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];

                return PropertyCard(
                  property: property,
                  onTap: () {
                     Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsPage(
          propertyId: property.id,
        ),
      ),
    );
                    
                    // Property details will be connected next.
                  },
                );
              },
            ),
          );
        },
      );
    
  }
}