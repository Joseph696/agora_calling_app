import 'package:agora_calling_app/providers/auth_provider.dart';
import 'package:agora_calling_app/screens/auth/registration_screen.dart';
import 'package:agora_calling_app/screens/home_screen.dart';
import 'package:agora_calling_app/widgets/custom_button.dart';
import 'package:agora_calling_app/widgets/custom_textfield.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<AuthController>(
      context,
    );

    return Scaffold(

      backgroundColor:
          const Color(
        0xFF0F172A,
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.symmetric(

            horizontal: 24,

            vertical: 20,
          ),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const SizedBox(
                height: 40,
              ),

              /// LOGO
              Center(

                child: Container(

                  height: 110,

                  width: 110,

                  decoration:
                      BoxDecoration(

                    shape:
                        BoxShape.circle,

                    color:
                        const Color(
                      0xFF4F46E5,
                    ).withOpacity(
                      0.15,
                    ),

                    border: Border.all(

                      color:
                          const Color(
                        0xFF4F46E5,
                      ).withOpacity(
                        0.4,
                      ),

                      width: 2,
                    ),
                  ),

                  child: const Icon(

                    Icons.call,

                    color:
                        Color(
                      0xFF4F46E5,
                    ),

                    size: 50,
                  ),
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              /// TITLE
              const Text(

                'Welcome Back',

                style: TextStyle(

                  color:
                      Colors.white,

                  fontSize: 30,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(

                'Login to continue receiving calls',

                style: TextStyle(

                  color:
                      Colors.white
                          .withOpacity(
                    0.6,
                  ),

                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              /// EMAIL
              CustomTextField(

                controller:
                    emailController,

                hintText:
                    'Email',
              ),

              const SizedBox(
                height: 20,
              ),

              /// PASSWORD
              CustomTextField(

                controller:
                    passwordController,

                hintText:
                    'Password',

                obscureText:
                    true,
              ),

              const SizedBox(
                height: 35,
              ),

              /// LOGIN BUTTON
              provider.isLoading

                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )

                  : SizedBox(

                      width:
                          double.infinity,

                      child:
                          CustomButton(

                        title:
                            'Login',

                        onTap:
                            () async {

                          try {

                            await provider.login(

                              email:
                                  emailController
                                      .text
                                      .trim(),

                              password:
                                  passwordController
                                      .text
                                      .trim(),
                            );

                            if (context
                                .mounted) {

                              Navigator.pushReplacement(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      const ReceiverHomeScreen(),
                                ),
                              );
                            }

                          } catch (e) {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              SnackBar(

                                backgroundColor:
                                    Colors.red,

                                content:
                                    Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

              const SizedBox(
                height: 24,
              ),

              /// REGISTER
              Center(

                child: TextButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const RegisterScreen(),
                      ),
                    );
                  },

                  child: RichText(

                    text: TextSpan(

                      children: [

                        TextSpan(

                          text:
                              'Don\'t have an account? ',

                          style: TextStyle(

                            color:
                                Colors.white
                                    .withOpacity(
                              0.6,
                            ),
                          ),
                        ),

                        const TextSpan(

                          text:
                              'Create Account',

                          style: TextStyle(

                            color:
                                Color(
                              0xFF4F46E5,
                            ),

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}