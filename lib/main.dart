import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ShortUrlApp());
}

class ShortUrlApp extends StatefulWidget {
  const ShortUrlApp({Key? key}) : super(key: key);

  @override
  _ShortUrlAppState createState() => _ShortUrlAppState();
}

class _ShortUrlAppState extends State<ShortUrlApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
    );
  }
}
