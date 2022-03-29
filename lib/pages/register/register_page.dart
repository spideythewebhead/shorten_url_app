import 'package:app/app_theme.dart';
import 'package:app/dispose_container.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:app/pages/register/register_page_state.dart';
import 'package:app/state/app_state.dart';
import 'package:app/widgets/controlled_textfield.dart';
import 'package:app/widgets/loading_overlay.dart';
import 'package:app/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yar/yar.dart';

final registerPageStateProvider = StateNotifierProvider.autoDispose<
    RegisterPageStateNotifier, RegisterPageState>(
  (ref) {
    return RegisterPageStateNotifier(ref);
  },
);

class RegisterPage extends ConsumerStatefulWidget {
  static const path = '/register';

  const RegisterPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  var _disposableContainer = DisposableContainer();

  @override
  void initState() {
    super.initState();

    _disposableContainer += ref
        .read(registerPageStateProvider.notifier)
        .eventStream
        .listen(_onEventReceived);
  }

  void _onEventReceived(RegisterPageEvent event) {
    event.when(
      registered: () {
        ref.watch(appStateProvider.notifier).tryLogin();
        context.router.popUntilAndPush('', HomePage.path);
      },
      error: () {
        debugPrint('error');
      },
    );
  }

  @override
  void dispose() {
    _disposableContainer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerPageStateProvider);
    final stateNotifier = ref.watch(registerPageStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: state.isLoading,
          child: Padding(
            padding: AppSpacing.paddingAll8,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSpacing.verticalMargin8,
                      ControlledTextFormField(
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
                        validator: (_) =>
                            state.passwordError?.translatedError(),
                      ),
                      AppSpacing.verticalMargin8,
                      ElevatedButton(
                        key: const Key('button-sign-up'),
                        child: const Text('Sign Up'),
                        onPressed: stateNotifier.canSignUp
                            ? stateNotifier.signUp
                            : null,
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  fillOverscroll: false,
                  hasScrollBody: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Spacer(),
                      AppLogo(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
