import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/core/hive_service.dart';
import 'package:notification_flutter_app/core/locator.dart';

class FancyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isNoticationButtoonVisible;
  final bool islogoutButtoonVisible;

  const FancyAppBar({
    super.key,
    required this.title,
    this.isNoticationButtoonVisible = false,
    this.islogoutButtoonVisible = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80.0); // Custom height

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16)), // Rounded bottom
      child: Container(
        height: preferredSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent, // Make AppBar itself transparent
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          //centerTitle: true,
          actions: [
            if (isNoticationButtoonVisible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AnimateIcon(
                  color: Colors.white,
                  key: UniqueKey(),
                  onTap: () {},
                  iconType: IconType.continueAnimation,
                  width: 32,
                  animateIcon: AnimateIcons.bell,
                ),
              ),
            if (islogoutButtoonVisible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AnimateIcon(
                  color: Colors.white,
                  key: UniqueKey(),
                  onTap: () {
                    locator.get<HiveService>().clearAllMobileUsersData();
                    context.pushReplacement(
                      '/loginPage',
                    );
                  },
                  iconType: IconType.continueAnimation,
                  width: 32,
                  animateIcon: AnimateIcons.signOut,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
