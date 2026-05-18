import 'package:agora_calling_app/providers/auth_provider.dart';
import 'package:agora_calling_app/screens/home_screen.dart';
import 'package:agora_calling_app/widgets/custom_button.dart';
import 'package:agora_calling_app/widgets/custom_textfield.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final nameController =
      TextEditingController();

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

                    Icons.person_add_alt_1,

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

                'Create Account',

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

                'Register to receive and manage calls',

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

              /// NAME
              CustomTextField(

                controller:
                    nameController,

                hintText:
                    'Full Name',
              ),

              const SizedBox(
                height: 20,
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

              /// REGISTER BUTTON
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
                            'Create Account',

                        onTap:
                            () async {

                          final name =
                              nameController
                                  .text
                                  .trim();

                          final email =
                              emailController
                                  .text
                                  .trim();

                          final password =
                              passwordController
                                  .text
                                  .trim();

                          if (name.isEmpty) {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(

                                backgroundColor:
                                    Colors.red,

                                content: Text(
                                  'Please enter your name',
                                ),
                              ),
                            );

                            return;
                          }

                          if (!email.endsWith(
                            '@gmail.com',
                          )) {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(

                                backgroundColor:
                                    Colors.red,

                                content: Text(
                                  'Please enter a valid Gmail address',
                                ),
                              ),
                            );

                            return;
                          }

                          if (password.length <
                              6) {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(

                                backgroundColor:
                                    Colors.red,

                                content: Text(
                                  'Password must be at least 6 characters',
                                ),
                              ),
                            );

                            return;
                          }

                          try {

                            await provider.register(

                              name: name,

                              email: email,

                              password:
                                  password,
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

              /// LOGIN
              Center(

                child: TextButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  child: RichText(

                    text: TextSpan(

                      children: [

                        TextSpan(

                          text:
                              'Already have an account? ',

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
                              'Login',

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