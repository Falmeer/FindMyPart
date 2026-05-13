import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;

  const ConditionBadge({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final isNew = condition.toLowerCase() == 'new';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNew ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNew ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}
