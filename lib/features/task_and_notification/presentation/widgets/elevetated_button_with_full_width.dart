import 'package:flutter/material.dart';

class ElevatedButtonWithFullWidth extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonTitle;
  final IconData? icon;
  final Color? backgroundColor;

  const ElevatedButtonWithFullWidth({
    super.key,
    this.onPressed,
    required this.buttonTitle,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: icon != null
            ? Icon(
                icon,
                color: Colors.white,
              )
            : null,
        label: Text(
          buttonTitle.toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 16,
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: backgroundColor ?? Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
