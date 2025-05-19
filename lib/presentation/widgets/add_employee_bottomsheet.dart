import 'dart:ui';

import 'package:flutter/material.dart';

void showAddEmployeeBottomSheet({
  required BuildContext context,
  required Widget contentWidget,
  required Widget stickyWidget,
}) {
  showModalBottomSheet(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.95,
      minWidth: MediaQuery.sizeOf(context).width,
    ),

    context: context,
    isScrollControlled: true, // Allows the sheet to resize with keyboard
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2,
          sigmaY: 2,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.6,
            child: Column(
              children: [
                Expanded(child: contentWidget),

                // Sticky Submit Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: stickyWidget,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
