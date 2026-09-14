import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/property_image_provider.dart';

class PropertyImageGallery extends ConsumerWidget {
  final String propertyId;

  const PropertyImageGallery({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync =
        ref.watch(propertyImagesProvider(propertyId));

    return imagesAsync.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        return Container(
          height: 220,
          alignment: Alignment.center,
          child: const Text(
            'Unable to load property images',
          ),
        );
      },
      data: (images) {
        if (images.isEmpty) {
          return Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text('No images available'),
              ],
            ),
          );
        }

        return SizedBox(
          height: 260,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                        ),
                      );
                    },
                    loadingBuilder:
                        (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}