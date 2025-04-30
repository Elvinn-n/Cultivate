import 'package:flutter/material.dart';
import 'screens/initial/splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/initial/sign_in_screen.dart'; // Correct import for SignInScreen

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const CulApp());
}

class CulApp extends StatelessWidget {
  const CulApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cul E-Commerce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Set the global font family
      ),
      home: const SplashScreen(), // SplashScreen is the starting screen
      debugShowCheckedModeBanner: false, // Removes the debug banner
      routes: {
        '/login': (context) => const SignInScreen(), // Define the /login route to SignInScreen
        // You will add other routes here as well, for example:
        // '/buyer_home': (context) => const BuyerHomeScreen(),
        // '/seller_home': (context) => const SellerHomeScreen(),
      },
    );
  }
}