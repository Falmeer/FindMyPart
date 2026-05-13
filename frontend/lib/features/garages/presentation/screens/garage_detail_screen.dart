import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/contact_button.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../providers/garages_provider.dart';

class GarageDetailScreen extends ConsumerWidget {
  final int id;
  const GarageDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageAsync = ref.watch(garageDetailProvider(id));
    final theme = Theme.of(context);

    return garageAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: ErrorState(message: e.toString())),
      data: (garage) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: NetworkImageWidget(
                  imageUrl: garage.thumbnailUrl,
                  height: 240,
                  width: double.infinity,
                  placeholderIcon: Icons.car_repair,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(garage.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: garage.rating,
                          itemSize: 16,
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: AppColors.starRating),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${garage.rating.toStringAsFixed(1)} · ${garage.reviewCount} reviews',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (garage.address != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(garage.address!,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ],
                    if (garage.workingHours != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(garage.workingHours!, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                    const Divider(height: 28),
                    Text('Services', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: garage.services
                          .map((s) => Chip(
                                label: Text(s, style: const TextStyle(fontSize: 13)),
                                backgroundColor: AppColors.primaryLight,
                              ))
                          .toList(),
                    ),
                    const Divider(height: 28),
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(garage.description,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/garages/post-issue'),
                            icon: const Icon(Icons.report_problem_outlined, size: 18),
                            label: const Text('Post Issue'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (garage.latitude != null && garage.longitude != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => launchUrl(Uri.parse(
                                  'https://maps.google.com/?q=${garage.latitude},${garage.longitude}')),
                              icon: const Icon(Icons.map_outlined, size: 18),
                              label: const Text('Directions'),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: garage.userId != null
            ? Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 20,
                        offset: const Offset(0, -4))
                  ],
                ),
                child: Row(
                  children: [
                    FavoriteButton(
                      type: 'garage',
                      id: garage.id,
                      initialValue: garage.isFavorited,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ContactButton(
                        recipientId: garage.userId!,
                        recipientName: garage.name,
                        expanded: false,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
