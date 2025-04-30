import 'package:flutter/material.dart';
import 'sign_in_screen.dart'; // Import for the Sign In screen
import 'gateway_screen.dart'; // Import for the Gateway screen

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Section
      appBar: AppBar(
        title: const Text(
          'Cultivate', // Title of the AppBar
          style: TextStyle(
            fontSize: 20, // Font size for the AppBar title
            color: Colors.white, // Text color for the AppBar title
            fontWeight: FontWeight.bold, // Font weight for the AppBar title
          ),
        ),
        backgroundColor: Colors.black, // Set AppBar background color to black
      ),

      // Body Section
      body: Container(
        color: Colors.black, // Set the background color of the screen to black
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons vertically
            children: [
              // Sign In Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Sign In screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Set button background color to white
                  foregroundColor: Colors.black, // Set button text color to black
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40, // Horizontal padding for the button
                    vertical: 15, // Vertical padding for the button
                  ),
                ),
                child: const Text(
                  'Sign In', // Text inside the Sign In button
                  style: TextStyle(
                    fontSize: 28, // Font size for the button text
                    fontWeight: FontWeight.w500, // Font weight for the button text
                  ),
                ),
              ),

              const SizedBox(height: 20), // Add spacing between the buttons

              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Gateway screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GatewayScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Set button background color to white
                  foregroundColor: Colors.black, // Set button text color to black
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40, // Horizontal padding for the button
                    vertical: 15, // Vertical padding for the button
                  ),
                ),
                child: const Text(
                  'Sign Up', // Text inside the Sign Up button
                  style: TextStyle(
                    fontSize: 28, // Font size for the button text
                    fontWeight: FontWeight.w500, // Font weight for the button text
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