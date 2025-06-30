import 'package:flutter/material.dart';

class ElevatedButtonWithFullWidth extends StatelessWidget {
  final void Function()? onPressed;
  final String buttonTitle;

  const ElevatedButtonWithFullWidth({
    super.key,
    this.onPressed,
    required this.buttonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 16,
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        buttonTitle,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
