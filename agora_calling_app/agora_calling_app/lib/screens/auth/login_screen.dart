import 'package:agora_calling_app/providers/auth_provider.dart';

import 'package:agora_calling_app/screens/auth/registration_screen.dart';

import 'package:agora_calling_app/screens/home_screen.dart';

import 'package:agora_calling_app/widgets/custom_button.dart';

import 'package:agora_calling_app/widgets/custom_textfield.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class LoginScreen
    extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen>
      createState() =>
          _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final formKey =
      GlobalKey<FormState>();

  Future<void> login() async {

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
        context.read<AuthController>();

    try {

      await provider.login(

        email:
            emailController.text
                .trim(),

        password:
            passwordController.text
                .trim(),
      );

      if (context.mounted) {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const UserListScreen(),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {

      String message =
          'Login failed';

      if (e.code ==
          'user-not-found') {

        message =
            'No account found with this email';

      } else if (e.code ==
          'wrong-password') {

        message =
            'Incorrect password';

      } else if (e.code ==
          'invalid-email') {

        message =
            'Invalid email address';

      } else if (e.code ==
          'invalid-credential') {

        message =
            'Invalid email or password';
      }

      showSnackBar(message);

    } catch (e) {

      showSnackBar(
        e.toString(),
      );
    }
  }

  void showSnackBar(
    String message,
  ) {

    ScaffoldMessenger.of(context)

        .showSnackBar(

      SnackBar(

        backgroundColor:
            Colors.redAccent,

        behavior:
            SnackBarBehavior.floating,

        content: Text(
          message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<AuthController>(
      context,
    );

    return Scaffold(

      backgroundColor:
          const Color(
        0xff0F172A,
      ),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.symmetric(

              horizontal: 24,
            ),

            child: Form(

              key: formKey,

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const SizedBox(
                    height: 30,
                  ),

                  const Text(

                    'Welcome Back',

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontSize: 34,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    'Login to continue your secure video calls',

                    style: TextStyle(

                      color:
                          Colors.white
                              .withOpacity(
                        0.7,
                      ),

                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  const Text(

                    'Email',

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  CustomTextField(

                    controller:
                        emailController,

                    hintText:
                        'Enter your email',
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  const Text(

                    'Password',

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  CustomTextField(

                    controller:
                        passwordController,

                    hintText:
                        'Enter your password',

                    obscureText:
                        true,
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  provider.isLoading

                      ? const Center(

                          child:
                              CircularProgressIndicator(
                            color:
                                Color(
                              0xff10B981,
                            ),
                          ),
                        )

                      : SizedBox(

                          width:
                              double.infinity,

                          child:
                              CustomButton(

                            title:
                                'Login',

                            onTap: login,
                          ),
                        ),

                  const SizedBox(
                    height: 30,
                  ),

                  Center(

                    child: Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [

                        Text(

                          'Don’t have an account?',

                          style: TextStyle(

                            color:
                                Colors.white
                                    .withOpacity(
                              0.7,
                            ),
                          ),
                        ),

                        TextButton(

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const RegisterScreen(),
                              ),
                            );
                          },

                          child: const Text(

                            'Register',

                            style: TextStyle(

                              color:
                                  Color(
                                0xff10B981,
                              ),

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}