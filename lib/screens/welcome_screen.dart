import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Navigate to main app after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildLogo(),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/icons/logo.png',
      height: 150,
      errorBuilder: (context, error, stackTrace) {
        return _buildTextLogo();
      },
    );
  }

  Widget _buildTextLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Trip B',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 0, right: 0, bottom: 2),
          child: Icon(
            Icons.public,
            size: 38,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          'nd',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
