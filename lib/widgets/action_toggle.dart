import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActionToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final bool isActive;
  final VoidCallback? onTap;

  const ActionToggle({
    super.key,
    required this.icon,
    required this.label,
    required this.status,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.lightGreen : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                  children: [
                     TextSpan(text: '$label: '),
                     TextSpan(
                      text: status,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
