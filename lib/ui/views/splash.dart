import 'package:d_reader_flutter/config/config.dart';
import 'package:d_reader_flutter/ui/shared/app_colors.dart';
import 'package:d_reader_flutter/ui/utils/screen_navigation.dart';
import 'package:d_reader_flutter/ui/widgets/d_reader_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  void afterSplash() {
    nextScreenReplace(context, const DReaderScaffold());
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), afterSplash);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.appBackgroundColor,
      body: Center(
        child: Column(
          children: [
            Text(
              'Connected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(
              height: 8,
            ),
            Lottie.asset(
              Config.successAuthAsset,
              alignment: Alignment.center,
              fit: BoxFit.cover,
              height: 200,
              width: 200,
              repeat: false,
            ),
          ],
        ),
      ),
    );
  }
}
