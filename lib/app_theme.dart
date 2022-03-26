import 'package:flutter/material.dart';

abstract class AppTheme {
  static const scaffoldColor = Color(0xff181818);
  static const dialogColor = Color(0xFF413D3D);
  static const primaryColor = Color(0xff967AA8);
  static const secondaryColor = Color(0xff30964A);
  static const bodyTextColor = Color(0xFFC8BACF);

  static const textTheme = TextTheme(
    bodyText1: TextStyle(
      fontSize: 16.0,
      color: bodyTextColor,
      fontWeight: FontWeight.w500,
    ),
    bodyText2: TextStyle(
      fontSize: 16.0,
      color: bodyTextColor,
    ),
    subtitle1: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
    ),
    subtitle2: TextStyle(
      fontSize: 15.0,
    ),
    caption: TextStyle(
      fontSize: 14.0,
    ),
    button: TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
    ),
  );

  static const radius = 4.0;
  static const borderRadius = BorderRadius.all(Radius.circular(radius));

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppTheme.primaryColor,
      secondary: AppTheme.secondaryColor,
    ),
    scaffoldBackgroundColor: AppTheme.scaffoldColor,
    dialogBackgroundColor: AppTheme.dialogColor,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textTheme: AppTheme.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppTheme.primaryColor,
    ),
    cardTheme: const CardTheme(
      color: AppTheme.dialogColor,
      margin: EdgeInsets.zero,
    ),
    iconTheme: const IconThemeData(
      size: 20.0,
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(88.0, 44.0),
        shape: const RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadius,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(88.0, 44.0),
        shape: const RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadius,
        ),
      ),
    ),
  );
}

class AppTextFieldDecoration extends InputDecoration {
  const AppTextFieldDecoration({
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? hintText,
  }) : super(
          border: const UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: AppTheme.borderRadius,
          ),
          filled: true,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        );
}

abstract class AppSpacing {
  static const paddingAll4 = EdgeInsets.all(4.0);
  static const paddingAll8 = EdgeInsets.all(8.0);
  static const paddingAll12 = EdgeInsets.all(12.0);

  static const paddingVertical12 = EdgeInsets.symmetric(vertical: 12.0);
  static const paddingHorizontal12 = EdgeInsets.symmetric(horizontal: 12.0);

  static const verticalMargin8 = SizedBox(height: 8.0);
  static const verticalMargin12 = SizedBox(height: 12.0);
  static const verticalMargin32 = SizedBox(height: 32.0);

  static const horizontalMargin4 = SizedBox(width: 4.0);
}
