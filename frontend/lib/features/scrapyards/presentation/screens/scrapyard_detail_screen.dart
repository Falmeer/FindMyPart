import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/contact_button.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../providers/scrapyards_provider.dart';

class ScrapyardDetailScreen extends ConsumerWidget {
  final int id;
  const ScrapyardDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrapyardAsync = ref.watch(scrapyardDetailProvider(id));
    final theme = Theme.of(context);

    return scrapyardAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: ErrorState(message: e.toString())),
      data: (scrapyard) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: NetworkImageWidget(
                  imageUrl: scrapyard.thumbnailUrl,
                  height: 240,
                  width: double.infinity,
                  placeholderIcon: Icons.recycling,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scrapyard.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: scrapyard.rating,
                          itemSize: 16,
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: AppColors.starRating),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${scrapyard.rating.toStringAsFixed(1)} · ${scrapyard.reviewCount} reviews',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (scrapyard.address != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(scrapyard.address!,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ],
                    if (scrapyard.workingHours != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(scrapyard.workingHours!, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                    if (scrapyard.services.isNotEmpty) ...[
                      const Divider(height: 28),
                      Text('Available Parts & Services', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: scrapyard.services
                            .map((s) => Chip(
                                  label: Text(s, style: const TextStyle(fontSize: 13)),
                                  backgroundColor: AppColors.primaryLight,
                                ))
                            .toList(),
                      ),
                    ],
                    const Divider(height: 28),
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(scrapyard.description,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    if (scrapyard.latitude != null && scrapyard.longitude != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => launchUrl(Uri.parse(
                              'https://maps.google.com/?q=${scrapyard.latitude},${scrapyard.longitude}')),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Get Directions'),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: scrapyard.userId != null
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
                      type: 'scrapyard',
                      id: scrapyard.id,
                      initialValue: scrapyard.isFavorited,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ContactButton(
                        recipientId: scrapyard.userId!,
                        recipientName: scrapyard.name,
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
