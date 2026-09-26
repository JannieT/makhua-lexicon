import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/extensions.dart';
import '../shared/models/async_state.dart';
import '../shared/services/service_locator.dart';
import '../shared/widgets/error_banner.dart';
import 'auth_manager.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  static const routeName = '/signin';

  @override
  SigninScreenState createState() => SigninScreenState();
}

class SigninScreenState extends State<SigninScreen> {
  late final AuthManager _auth;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: SizedBox(
            width: 340,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  Text(
                    context.tr.loginTitle,
                    textAlign: TextAlign.center,
                    style: context.styles.displayMedium,
                  ),
                  const Spacer(),
                  TextFormField(
                    autofocus: true,
                    controller: _emailController,
                    // style: context.styles.headlineLarge,
                    decoration: InputDecoration(hintText: context.tr.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return context.tr.emailRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    autocorrect: false,
                    // style: context.styles.headlineLarge,
                    decoration: InputDecoration(hintText: context.tr.password),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return context.tr.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SignalBuilder(builder: (context) {
                    final state = _auth.loginState;
                    final loading = state is AppAsyncLoading<bool>;
                    final error = switch (state) {
                      AppAsyncFailure(:final message) => message,
                      _ => null,
                    };

                    return Column(
                      children: [
                        SizedBox(
                          width: 325,
                          child: ElevatedButton(
                            onPressed: loading ? null : _login,
                            child: Text(context.tr.loginLabel),
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (error != null) ErrorBanner(message: error),
                      ],
                    );
                  }),
                  const Spacer(),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _auth.login(_emailController.text, _passwordController.text);
    if (!success || !mounted) return;

    context.go('/');
  }

  @override
  void initState() {
    super.initState();
    _auth = get<AuthManager>();
    _auth.resetLoginState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
