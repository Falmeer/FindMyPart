import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final _controller = PageController();

  static const _banners = [
    _BannerData(
      title: 'Find Salvaged Vehicles',
      subtitle: 'Browse thousands of cars available for parts',
      color: AppColors.primary,
      icon: Icons.directions_car,
    ),
    _BannerData(
      title: 'Quality Spare Parts',
      subtitle: 'New & used parts from trusted sellers',
      color: Color(0xFF059669),
      icon: Icons.build_circle_outlined,
    ),
    _BannerData(
      title: 'Nearby Garages',
      subtitle: 'Connect with professional repair shops',
      color: Color(0xFFD97706),
      icon: Icons.car_repair,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            itemBuilder: (_, i) => _BannerCard(data: _banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _controller,
          count: _banners.length,
          effect: const WormEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: AppColors.primary,
            dotColor: AppColors.border,
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.color, data.color.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle,
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(data.icon, color: Colors.white.withAlpha(180), size: 64),
          ],
        ),
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
