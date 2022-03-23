import 'package:app/app_theme.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:app/widgets/app_icon_button.dart';
import 'package:app/widgets/controlled_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateShortUrlTextField extends ConsumerStatefulWidget {
  const CreateShortUrlTextField({
    Key? key,
  }) : super(key: key);

  @override
  _CreateShortUrlTextFieldState createState() =>
      _CreateShortUrlTextFieldState();
}

class _CreateShortUrlTextFieldState
    extends ConsumerState<CreateShortUrlTextField> {
  final _urlRegExp = RegExp(r'^(http(s)?://)?[\w@-]+(\.\w{2,})+$');

  var _url = '';
  var _hasError = true;

  void _onUrlChanged(String url) {
    setState(() {
      _url = url.trim();
      _hasError = !_urlRegExp.hasMatch(_url);
    });
  }

  void _onSubmit() {
    if (!_hasError) {
      ref.watch(homePageStateProvider.notifier).createUrl(_url);
      setState(() {
        _url = '';
        _hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControlledTextFormField(
      decoration: AppTextFieldDecoration(
        hintText: 'https://my-long-url/here',
        prefixIcon: const Icon(Icons.link),
        suffixIcon: _hasError
            ? null
            : AppIconButton(
                icon: const Icon(Icons.done),
                onPressed: _onSubmit,
              ),
      ),
      textAlignVertical: TextAlignVertical.center,
      onChanged: _onUrlChanged,
      value: _url,
    );
  }
}
