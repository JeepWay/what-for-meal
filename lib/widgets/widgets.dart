import 'package:flutter/material.dart';

class PrimaryTextButton extends StatelessWidget {
  const PrimaryTextButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: onPressed,
      style: (style != null) ? style : TextButton.styleFrom(
        backgroundColor: theme.colorScheme.onPrimary,
        foregroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: theme.textTheme.titleMedium,
      ),
      label: label,
    );
  }
}


class PrimaryElevatedButton extends StatelessWidget {
  const PrimaryElevatedButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: (style != null) ? style : ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        iconColor: Colors.black,
        iconSize: 25,
        textStyle: theme.textTheme.titleMedium,
      ),
    );
  }
}


class WhiteElevatedButton extends StatelessWidget {
  const WhiteElevatedButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: (style != null) ? style : ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        iconColor: Colors.black,
        iconSize: 25,
        textStyle: theme.textTheme.titleMedium,
      ),
    );
  }
}

