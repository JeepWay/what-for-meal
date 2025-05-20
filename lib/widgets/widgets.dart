import 'package:flutter/material.dart';

class TransparentTextButton extends StatelessWidget {
  const TransparentTextButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: (style != null) ? style : TextButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: BorderSide.none,
        textStyle: theme.textTheme.titleMedium,
      ),
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
        textStyle: theme.textTheme.titleMedium,
      ),
    );
  }
}


class PrimaryOutlinedButton extends StatelessWidget {
  const PrimaryOutlinedButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: (style != null) ? style : OutlinedButton.styleFrom(
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
        textStyle: theme.textTheme.titleMedium,
      ),
    );
  }
}

class WhiteOutlinedButton extends StatelessWidget {
  const WhiteOutlinedButton({super.key, this.icon, required this.label, required this.onPressed, this.style});

  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: (style != null) ? style : OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        textStyle: theme.textTheme.titleMedium,
      ),
    );
  }
}
