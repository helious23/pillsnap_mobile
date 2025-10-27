import 'package:flutter/material.dart';
import '../../theme.dart';

class ZoomSelector extends StatelessWidget {
  final double currentZoom;
  final void Function(double) onZoomChanged;

  const ZoomSelector({
    super.key,
    required this.currentZoom,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomOption(
            zoom: 1.0,
            label: '1x',
            isSelected: currentZoom == 1.0,
            onTap: () => onZoomChanged(1.0),
          ),
          _ZoomOption(
            zoom: 2.0,
            label: '2x',
            isSelected: currentZoom == 2.0,
            onTap: () => onZoomChanged(2.0),
          ),
          _ZoomOption(
            zoom: 3.0,
            label: '3x',
            isSelected: currentZoom == 3.0,
            onTap: () => onZoomChanged(3.0),
          ),
        ],
      ),
    );
  }
}

class _ZoomOption extends StatelessWidget {
  final double zoom;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ZoomOption({
    required this.zoom,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}