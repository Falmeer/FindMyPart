import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PriceTag extends StatelessWidget {
  final double? price;
  final String? label;
  final double fontSize;

  const PriceTag({super.key, this.price, this.label, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    final text = price != null
        ? 'BHD ${price!.toStringAsFixed(0)}'
        : (label ?? 'Contact for price');

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: price != null ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
