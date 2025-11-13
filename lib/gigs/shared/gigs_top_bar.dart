import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GigsTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GigsTopBar({
    super.key,
    this.title = 'Gigs',
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF163A63);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: navy,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
