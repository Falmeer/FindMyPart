import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../data/models/garage_model.dart';

class GarageCard extends StatelessWidget {
  final GarageModel garage;

  const GarageCard({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/garages/${garage.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            NetworkImageWidget(
              imageUrl: garage.thumbnailUrl,
              width: 72,
              height: 72,
              borderRadius: BorderRadius.circular(12),
              placeholderIcon: Icons.car_repair,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garage.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (garage.address != null)
                    Text(
                      garage.address!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: garage.rating,
                        itemSize: 14,
                        itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starRating),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${garage.rating.toStringAsFixed(1)} (${garage.reviewCount})',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (garage.distanceKm != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${garage.distanceKm!.toStringAsFixed(1)} km away',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
