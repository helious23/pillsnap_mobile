import 'package:flutter/material.dart';
import 'package:pillsnap/theme/app_typography.dart';
import 'package:pillsnap/theme/app_spacing.dart';

/// 카메라 컨트롤 (줌/개수 선택, 촬영 버튼, 플래시)
class CameraControls extends StatelessWidget {
  final double currentZoom;
  final void Function(double) onZoomChanged;
  final VoidCallback onCapture;
  final bool isCapturing;
  final bool isMultiMode;
  final int pillCount;
  final void Function(int) onPillCountChanged;
  final bool isFlashOn;
  final VoidCallback onFlashToggle;
  final VoidCallback? onGalleryTap;
  
  const CameraControls({
    super.key,
    required this.currentZoom,
    required this.onZoomChanged,
    required this.onCapture,
    this.isCapturing = false,
    this.isMultiMode = false,
    this.pillCount = 2,
    required this.onPillCountChanged,
    required this.isFlashOn,
    required this.onFlashToggle,
    this.onGalleryTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 줌 컨트롤 또는 개수 선택
            isMultiMode
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CountButton(
                        label: '2개',
                        isSelected: pillCount == 2,
                        onTap: () => onPillCountChanged(2),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _CountButton(
                        label: '3개',
                        isSelected: pillCount == 3,
                        onTap: () => onPillCountChanged(3),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _CountButton(
                        label: '4개',
                        isSelected: pillCount == 4,
                        onTap: () => onPillCountChanged(4),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ZoomButton(
                        label: '1x',
                        isSelected: currentZoom == 1.0,
                        onTap: () => onZoomChanged(1.0),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _ZoomButton(
                        label: '2x',
                        isSelected: currentZoom == 2.0,
                        onTap: () => onZoomChanged(2.0),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _ZoomButton(
                        label: '3x',
                        isSelected: currentZoom == 3.0,
                        onTap: () => onZoomChanged(3.0),
                      ),
                    ],
                  ),
            const SizedBox(height: AppSpacing.xl),
            
            // 촬영 버튼과 플래시/갤러리 버튼
            SizedBox(
              width: 280,  // Stack 너비 확장
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 중앙에 촬영 버튼
                  Center(
                    child: GestureDetector(
                      onTap: isCapturing ? null : onCapture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCapturing 
                                ? Colors.grey 
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 좌측에 갤러리 버튼
                  Positioned(
                    left: 0,
                    top: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onGalleryTap,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  // 우측에 플래시 버튼
                  Positioned(
                    right: 0,
                    top: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onFlashToggle,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _ZoomButton({
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
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CountButton({
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
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}