import 'package:flutter/material.dart';
import '../../theme.dart';

class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool fullWidth;
  final EdgeInsets? margin;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fullWidth = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}