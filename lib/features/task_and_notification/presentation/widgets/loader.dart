import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class LoaderDialog {
  static void show({required BuildContext context, String? path}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                ),
                child: Lottie.asset(
                  'assets/animations/${path ?? 'launching.json'}',
                  width: double.infinity,
                  height: double.infinity,
                  repeat: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void hide({
    required BuildContext context,
  }) {
    context.pop();
  }
}
