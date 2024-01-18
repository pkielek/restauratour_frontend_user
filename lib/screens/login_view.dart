import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:utils/utils.dart';

class LoginView extends ConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: SingleChildScrollView(
        child: SizedBox(
          height: size.height*0.98,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'images/logo.webp',
                semanticLabel: 'Restaura TOUR Logo',
                width: size.width * 0.4,
                height: size.height * 0.4,
              ),
              const Center(
                  child: SelectableText("Witaj w RestauraTOUR!", style: boldBig)),
              Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EmailField(
                            onChanged: ref
                                .read(LoginProvider(AuthType.user).notifier)
                                .updateEmail,
                            onSubmit: ref
                                .read(LoginProvider(AuthType.user).notifier)
                                .login),
                        const SizedBox(height: 15),
                        PasswordField(
                            type: AuthType.user,
                            onSubmit: ref
                                .read(LoginProvider(AuthType.user).notifier)
                                .login),
                        const SizedBox(height: 15),
                        RoundedLoadingButton(
                          color: primaryColor,
                          successIcon: Icons.done,
                          failedIcon: Icons.close,
                          resetAfterDuration: true,
                          resetDuration: const Duration(seconds: 2),
                          width: 2000,
                          controller: _submitController,
                          onPressed:
                              ref.read(LoginProvider(AuthType.user).notifier).login,
                          child: const Text('Zaloguj się!',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 15),
                        SelectableText(
                            ref.watch(LoginProvider(AuthType.user)).when(
                                data: (data) => data.errorMessage,
                                error: (_, __) => "Niespodziewany błąd",
                                loading: () => ""),
                            style: const TextStyle(color: Colors.red)),
                        DefaultButton(
                            callback: () =>
                                Routemaster.of(context).push("register"),
                            text: "Zarejestruj się"),
                        SocialLoginButton(
                            buttonType: SocialLoginButtonType.google,
                            onPressed: () async {
                              final signIn = GoogleSignIn(
                                  scopes: ['email', 'profile', 'openid']);
                              await signIn.signOut();
                              final data = await signIn.signIn();
                              if (data == null) return;
                              final auth = await data.authentication;
                              try {
                                final response = await Dio().post(
                                    '${dotenv.env['USER_API_URL']!}googlelogin',
                                    data: {"token": auth.idToken});
                                ref
                                    .read(authProvider.notifier)
                                    .login(response.data["access_token"]);
                              } on DioException catch (e) {
                                if (e.response != null) {
                                  Map responseBody = e.response!.data;
                                  fluttertoastDefault(responseBody['detail'], true);
                                } else {
                                  fluttertoastDefault(
                                      "Coś poszło nie tak! Spróbuj ponownie później",
                                      true);
                                }
                              }
                            },
                            text: "Zaloguj z Google"),
                      ])),
              const Center(
                  child: SelectableText(
                      "Piotr Kiełek © 2023 | Wszelkie prawa zastrzeżone",
                      style: footprintStyle)),
            ],
          ),
        ),
      ),
    ));
  }
}
