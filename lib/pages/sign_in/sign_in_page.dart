import 'package:app/app_theme.dart';
import 'package:app/dispose_container.dart';
import 'package:app/extensions/extensions.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:app/pages/register/register_page.dart';
import 'package:app/pages/sign_in/sign_in_page_state.dart';
import 'package:app/widgets/controlled_textfield.dart';
import 'package:app/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yar/yar.dart';

final signInPageStateProvider =
    StateNotifierProvider.autoDispose<SignInPageStateNotifier, SignInPageState>(
  (ref) {
    return SignInPageStateNotifier(ref: ref);
  },
);

class SignInPage extends ConsumerStatefulWidget {
  static const path = '/sign_in';

  const SignInPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  var _disposableContainer = DisposableContainer();

  @override
  void initState() {
    super.initState();

    _disposableContainer += ref
        .read(signInPageStateProvider.notifier)
        .eventStream
        .listen(_onEventReceived);
  }

  void signIn() {
    FocusScope.of(context).unfocus();
    ref.watch(signInPageStateProvider.notifier).signIn();
  }

  void onSignUp() {
    context.router.push(RegisterPage.path);
  }

  void _onEventReceived(SignInPageEvent event) {
    event.when(
      signed: () {
        context.router.popUntilAndPush('', HomePage.path);
      },
      error: () {},
    );
  }

  @override
  void dispose() {
    _disposableContainer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInPageStateProvider);
    final stateNotifier = ref.watch(signInPageStateProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: state.isLoading,
          child: Padding(
            padding: AppSpacing.paddingAll8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.verticalMargin32,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ControlledTextFormField(
                      key: const Key('textfield-email'),
                      decoration: const AppTextFieldDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      value: state.email,
                      onChanged: stateNotifier.emailChanged,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (_) => state.emailError?.translatedError(),
                    ),
                    AppSpacing.verticalMargin8,
                    ControlledTextFormField(
                      key: const Key('textfield-password'),
                      decoration: const AppTextFieldDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.password),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      value: state.password,
                      onChanged: stateNotifier.passwordChanged,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (_) => state.passwordError?.translatedError(),
                    ),
                    AppSpacing.verticalMargin8,
                    ElevatedButton(
                      key: const Key('button-sign-in'),
                      child: const Text('Sign In'),
                      onPressed: stateNotifier.canSignIn ? signIn : null,
                    )
                  ],
                ),
                AppSpacing.verticalMargin12,
                const Text('Or', textAlign: TextAlign.center),
                TextButton(
                  key: const Key('button-sign-up'),
                  child: const Text('Sign Up'),
                  onPressed: onSignUp,
                ),
                // const Divider(),
                // TextButton(
                //   key: const Key('button-continue-as-guest'),
                //   child: const Text('Continue as anonymous'),
                //   onPressed: () {},
                // ),
                // AppSpacing.verticalMargin8,
                // Text(
                //   'Your history will be lost if you re-install the app.\n'
                //   'Also your links will be erased after the end of day.',
                //   style: context.theme.textTheme.caption,
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
