import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';

class RegisterView extends ConsumerWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        primary: true,
        title: const Text("Zarejestruj się", style: headerStyle),
        toolbarOpacity: 1.0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              child:RegisterFields(type: AuthType.user)
            ),
          ),
        ),
      ),
    );
  }
}
