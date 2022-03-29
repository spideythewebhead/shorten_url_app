import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    Key? key,
    this.height = 196.0,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logos/logo_transparent.png',
      height: height,
    );
  }
}
