import 'package:flutter/material.dart';

import '../../models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      property.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    '₹${property.monthlyRent.toStringAsFixed(0)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                property.type,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 4),

              Text(
                '${property.addressLine}, ${property.city}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (property.bedrooms != null)
                    _InfoItem(
                      icon: Icons.bed_outlined,
                      text: '${property.bedrooms} Beds',
                    ),

                  if (property.bathrooms != null)
                    _InfoItem(
                      icon: Icons.bathtub_outlined,
                      text: '${property.bathrooms} Baths',
                    ),

                  if (property.areaSqFt != null)
                    _InfoItem(
                      icon: Icons.square_foot,
                      text:
                          '${property.areaSqFt!.toStringAsFixed(0)} sq.ft',
                    ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Security deposit: ₹${property.securityDeposit?.toStringAsFixed(0) ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}