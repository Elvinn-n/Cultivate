import 'package:flutter/material.dart';
import 'auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) { // Ensure the widget is still mounted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Center(
        child: Image.asset(
          'assets/images/CulApp_dark_logo.png', // Updated logo path
          height: 150, // Adjust the size as needed
        ),
      ),
    );
  }
}