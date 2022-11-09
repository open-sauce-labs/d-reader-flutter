import 'package:d_reader_flutter/config/config.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          Config.logoTextPath,
        ),
      ),
      leadingWidth: 164,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      actions: const [
        Icon(
          Icons.notifications_none,
        ),
        SizedBox(
          width: 8,
        ),
        Icon(
          Icons.person_outline,
        ),
      ],
    );
  }
}