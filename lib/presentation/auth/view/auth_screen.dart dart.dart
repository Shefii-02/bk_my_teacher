import 'package:app/presentation/auth/view/signin_screen.dart';
import 'package:app/presentation/auth/view/signup_stepper.dart';

import 'package:flutter/material.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: PageController(initialPage: 0),
        children: const [
          SignInScreen(),
          SignUpStepper(),
        ],
      ),
    );
  }
}
