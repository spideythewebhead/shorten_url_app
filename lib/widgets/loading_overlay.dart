import 'package:app/extensions/extensions.dart';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    Key? key,
    this.isLoading = false,
    required this.child,
  }) : super(key: key);

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AbsorbPointer(
            absorbing: true,
            child: ColoredBox(
              color: context.theme.scaffoldBackgroundColor.withOpacity(.45),
              child: const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(),
              ),
            ),
          )
      ],
    );
  }
}
