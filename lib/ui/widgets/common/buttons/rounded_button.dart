import 'package:d_reader_flutter/ui/shared/app_colors.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final void Function() onPressed;
  final Size size;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = ColorPalette.dReaderYellow100,
    this.textColor = ColorPalette.appBackgroundColor,
    this.size = const Size(120, 27),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: size,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              8,
            ),
          ),
        ),
        foregroundColor: textColor,
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ColorPalette.boxBackground200,
              fontWeight: FontWeight.w700,
            ),
      ),
      child: Text(text),
    );
  }
}
