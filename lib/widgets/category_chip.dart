import 'package:flutter/material.dart';
import 'package:news_app/utils/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary 
                  : (isDark ? AppColors.darkSurface : Colors.grey[100]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? AppColors.darkDivider : AppColors.divider),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
