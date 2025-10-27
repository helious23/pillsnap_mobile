import 'package:flutter/material.dart';
import '../../theme.dart';

class PillAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showBack;
  final bool showSettings;
  final bool showInfo;
  final Widget? trailing;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onInfoTap;
  final bool isDark;  // 다크 모드 지원

  const PillAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showBack = false,
    this.showSettings = false,
    this.showInfo = false,
    this.trailing,
    this.onBackTap,
    this.onSettingsTap,
    this.onInfoTap,
    this.isDark = false,  // 기본값은 밝은 모드
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? Colors.transparent : AppColors.background;
    final foregroundColor = isDark ? Colors.white : AppColors.textPrimary;
    final logoColor = isDark ? Colors.white : AppColors.primary;
    
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBackTap ?? () => Navigator.of(context).pop(),
              color: foregroundColor,
            )
          : null,
      title: showLogo
          ? Text(
              'PillSnap',
              style: AppTextStyles.h3.copyWith(
                color: logoColor,
                fontWeight: FontWeight.w700,
              ),
            )
          : title != null
              ? Text(
                  title!,
                  style: AppTextStyles.h3.copyWith(
                    color: foregroundColor,
                  ),
                )
              : null,
      actions: [
        if (showInfo)
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: onInfoTap,
            color: foregroundColor,
          ),
        if (showSettings)
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: onSettingsTap,
            color: foregroundColor,
          ),
        if (trailing != null) trailing!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}