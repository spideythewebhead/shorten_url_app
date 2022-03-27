import 'package:app/app_theme.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:app/widgets/app_icon_button.dart';
import 'package:app/widgets/controlled_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'short_url_textfield.freezed.dart';

@freezed
class UrlCreationState with _$UrlCreationState {
  const factory UrlCreationState({
    @Default('') String url,
    @Default(false) bool canSubmit,
  }) = _State;
}

class UrlCreationNotifier extends StateNotifier<UrlCreationState> {
  UrlCreationNotifier(
    this._ref,
  ) : super(const UrlCreationState());

  final Ref _ref;

  final _urlRegExp =
      RegExp(r'^(http(s)?://)[\w@-_]+(\.\w{2,})+[/ \w\d=@-_?&%]*$');

  void updateUrl(String url) {
    state = state.copyWith(
      url: url,
      canSubmit: _urlRegExp.hasMatch(url),
    );
  }

  void submit() {
    if (state.canSubmit) {
      _ref.read(homePageStateProvider.notifier).createUrl(state.url);
      state = const UrlCreationState();
    }
  }
}

final urlCreationStateProvider =
    StateNotifierProvider<UrlCreationNotifier, UrlCreationState>(
  (ref) => UrlCreationNotifier(ref),
);

class CreateShortUrlTextField extends ConsumerWidget {
  const CreateShortUrlTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(urlCreationStateProvider);
    final stateNotifier = ref.watch(urlCreationStateProvider.notifier);

    return ControlledTextFormField(
      key: const Key('textfield-create-url'),
      decoration: AppTextFieldDecoration(
        hintText: 'https://my-long-url/here',
        prefixIcon: const Icon(Icons.link),
        suffixIcon: state.canSubmit
            ? AppIconButton(
                icon: const Icon(Icons.done),
                onPressed: stateNotifier.submit,
              )
            : null,
      ),
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      textAlignVertical: TextAlignVertical.center,
      onChanged: stateNotifier.updateUrl,
      value: state.url,
      onFieldSubmitted: (_) {
        if (state.canSubmit) {
          stateNotifier.submit();
        }
      },
    );
  }
}
