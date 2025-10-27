import 'package:flutter/material.dart';
import '../../theme.dart';

class CrosshairOverlay extends StatelessWidget {
  final String guideText;
  final bool showCrosshair;

  const CrosshairOverlay({
    super.key,
    required this.guideText,
    this.showCrosshair = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 십자선 및 프레임
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              children: [
                // 네 모서리 코너
                const Positioned(
                  top: 0,
                  left: 0,
                  child: _CornerMark(isTop: true, isLeft: true),
                ),
                const Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerMark(isTop: true, isLeft: false),
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  child: _CornerMark(isTop: false, isLeft: true),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: _CornerMark(isTop: false, isLeft: false),
                ),
                // 십자선
                if (showCrosshair) ...[
                  // 가로선
                  Positioned(
                    top: 120,
                    left: 40,
                    right: 40,
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  // 세로선
                  Positioned(
                    left: 120,
                    top: 40,
                    bottom: 40,
                    child: Container(
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // 안내 말풍선
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                guideText,
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerMark extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerMark({
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }
}