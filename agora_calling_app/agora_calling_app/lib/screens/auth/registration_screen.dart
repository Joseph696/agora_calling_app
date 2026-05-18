import 'package:agora_calling_app/providers/auth_provider.dart';

import 'package:agora_calling_app/screens/auth/login_screen.dart';

import 'package:agora_calling_app/screens/home_screen.dart';

import 'package:agora_calling_app/widgets/custom_button.dart';

import 'package:agora_calling_app/widgets/custom_textfield.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AuthController>();

    try {
      await provider.register(
        name: nameController.text.trim(),

        email: emailController.text.trim(),

        password: passwordController.text.trim(),
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const UserListScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters';
      }

      showSnackBar(message);
    } catch (e) {
      showSnackBar(e.toString());
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,

        behavior: SnackBarBehavior.floating,

        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Form(
              key: formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'Create Account',

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 34,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Start secure and reliable video communication',

                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),

                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 45),

                  const Text(
                    'Full Name',

                    style: TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: nameController,

                    hintText: 'Enter your name',
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Email',

                    style: TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: emailController,

                    hintText: 'Enter your email',

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }

                      final email = value.trim();

                      final gmailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                      );

                      if (!gmailRegex.hasMatch(email)) {
                        return 'Enter a valid Gmail address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Password',

                    style: TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: passwordController,

                    hintText: 'Create password',

                    obscureText: true,
                  ),

                  const SizedBox(height: 35),

                  provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff10B981),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,

                          child: CustomButton(
                            title: 'Create Account',

                            onTap: register,
                          ),
                        ),

                  const SizedBox(height: 28),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          'Already have an account?',

                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },

                          child: const Text(
                            'Login',

                            style: TextStyle(
                              color: Color(0xff10B981),

                              fontWeight: FontWeight.bold,
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
