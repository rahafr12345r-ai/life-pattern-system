import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LifePatternBrand extends StatelessWidget {
  const LifePatternBrand({super.key, this.showLanguage = true});

  final bool showLanguage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLanguage)
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('العربية', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        if (showLanguage) const SizedBox(height: 22),
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            color: AppColors.primary,
            size: 43,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Life Pattern',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Early behavioral insights, with clarity and privacy',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.mutedText, fontSize: 15),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Text(
          'G',
          style: TextStyle(
            color: AppColors.googleBlue,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        label: const Text('Continue with Google'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
