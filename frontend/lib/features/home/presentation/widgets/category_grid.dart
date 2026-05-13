import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const _categories = [
    _CategoryData('Engine', Icons.settings, '/parts?category=engine'),
    _CategoryData('Transmission', Icons.alt_route, '/parts?category=transmission'),
    _CategoryData('Brakes', Icons.disc_full, '/parts?category=brakes'),
    _CategoryData('Suspension', Icons.compress, '/parts?category=suspension'),
    _CategoryData('Electrical', Icons.electric_bolt, '/parts?category=electrical'),
    _CategoryData('AC', Icons.ac_unit, '/parts?category=ac'),
    _CategoryData('Exterior', Icons.car_crash, '/parts?category=exterior'),
    _CategoryData('Lighting', Icons.light, '/parts?category=lighting'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _CategoryChip(data: _categories[i], colorIndex: i),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _CategoryData data;
  final int colorIndex;

  const _CategoryChip({required this.data, required this.colorIndex});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[colorIndex % AppColors.categoryColors.length];
    return GestureDetector(
      onTap: () => context.push(data.route),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Icon(data.icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String label;
  final IconData icon;
  final String route;
  const _CategoryData(this.label, this.icon, this.route);
}
