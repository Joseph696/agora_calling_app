import 'dart:async';
import 'package:agora_calling_app/screens/auth/login_screen.dart';
import 'package:agora_calling_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController pulseController;
  late AnimationController fadeController;
  late Animation<double> pulseAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    initializeAnimations();
    checkLogin();
  }

  void initializeAnimations() {
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    pulseAnimation = Tween<double>(
      begin: 0.92,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    ));

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeIn,
    ));

    fadeController.forward();
  }

  // ✅ Same functionality — SharedPreferences login check
  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('isLogin') ?? false;

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (isLogin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ReceiverHomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    pulseController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF111827),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ✅ Pulsing icon
                ScaleTransition(
                  scale: pulseAnimation,
                  child: Container(
                    height: 125,
                    width: 125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4F46E5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.45),
                          blurRadius: 35,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call_rounded,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ App name
                const Text(
                  'Agora Calling',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Tagline
                Text(
                  'Fast • Secure • Reliable',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 65),

                // ✅ Loading indicator
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}