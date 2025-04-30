import 'package:flutter/material.dart';
import 'buyer_sign_up_screen.dart'; // Import the BuyerSignUpScreen
import 'seller_sign_up_screen.dart'; // Import the SellerSignUpScreen

class GatewayScreen extends StatelessWidget {
  const GatewayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Section
      appBar: AppBar(
        title: const Text(
          'Select User Type', // Title of the AppBar
          style: TextStyle(
            fontSize: 20, // Font size for the AppBar title
            fontWeight: FontWeight.bold, // Font weight for the AppBar title
          ),
        ),
        backgroundColor: Colors.black, // Set AppBar background color to black
      ),

      // Body Section
      body: Container(
        color: Colors.black, // Set the background color to black
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons vertically
            children: [
              // Buyer Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Buyer Sign-Up screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuyerSignUpScreen(),
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
                  'Buyer', // Text inside the Buyer button
                  style: TextStyle(
                    fontSize: 20, // Font size for the button text
                    fontWeight: FontWeight.w500, // Font weight for the button text
                  ),
                ),
              ),

              const SizedBox(height: 20), // Add spacing between the buttons

              // Seller Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Seller Sign-Up screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellerSignUpScreen(),
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
                  'Seller', // Text inside the Seller button
                  style: TextStyle(
                    fontSize: 20, // Font size for the button text
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
