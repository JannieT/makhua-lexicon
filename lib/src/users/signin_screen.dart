import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/extensions.dart';
import '../shared/services/service_locator.dart';
import '../shared/services/store_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  static const routeName = '/signin';

  @override
  SigninScreenState createState() => SigninScreenState();
}

class SigninScreenState extends State<SigninScreen> {
  bool _isBusy = false;
  String _errorMessage = '';
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
                  SizedBox(
                    width: 325,
                    child: ElevatedButton(
                      onPressed: _isBusy ? null : _login,
                      child: Text(context.tr.loginLabel),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _errorMessage,
                    style: context.styles.bodyMedium?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
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

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isBusy = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final store = get<StoreService>();
      await store.saveCredentials(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _errorMessage = '';
        _isBusy = false;
      });

      if (!mounted) return;
      context.go('/');
    } on FirebaseAuthException catch (e) {
      final feedback = switch (e.code) {
        'user-not-found' => context.tr.userDoesntExistsWithGivenEmail,
        'wrong-password' => context.tr.invalidEmailOrPassword,
        'invalid-credential' => context.tr.invalidEmailOrPassword,
        _ => context.tr.somethingWentWrongPleaseTryAgain,
      };

      setState(() {
        _errorMessage = feedback;
      });
    }

    setState(() {
      _isBusy = false;
    });
  }

  Future<void> _loadSavedCredentials() async {
    final store = get<StoreService>();
    if (store.hasCredentials) {
      setState(() {
        _emailController.text = store.email ?? '';
        _passwordController.text = store.password ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isBusy = false;
    _errorMessage = '';
    _emailController = TextEditingController()..clear();
    _passwordController = TextEditingController()..clear();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
