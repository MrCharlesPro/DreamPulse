import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class BotonDegradado extends StatelessWidget {
  const BotonDegradado({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.height = 52,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final double height;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: onPressed == null ? null : AppConstants.degradado,
      color: onPressed == null
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : null,
      borderRadius: BorderRadius.circular(18),
    ),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          disabledForegroundColor: Theme.of(context).colorScheme.onSurface,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    ),
  );
}
