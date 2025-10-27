import 'package:flutter/material.dart';
import '../../theme.dart';

class FlashToggle extends StatelessWidget {
  final bool isOn;
  final VoidCallback onToggle;

  const FlashToggle({
    super.key,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOn ? Icons.flash_on : Icons.flash_off,
              size: 20,
              color: isOn ? Colors.yellow : Colors.white,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '자동',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}