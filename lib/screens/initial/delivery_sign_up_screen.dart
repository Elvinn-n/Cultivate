// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DeliverySignUpScreen extends StatefulWidget {
//   const DeliverySignUpScreen({Key? key}) : super(key: key);

//   @override
//   State<DeliverySignUpScreen> createState() => _DeliverySignUpScreenState();
// }

// class _DeliverySignUpScreenState extends State<DeliverySignUpScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _vehicleDetailsController = TextEditingController();
//   final TextEditingController _businessNameController = TextEditingController();

//   Future<void> _handleSignUp() async {
//     try {
//       final email = _emailController.text.trim();
//       final password = _passwordController.text.trim();
//       final name = _nameController.text.trim();
//       final vehicleDetails = _vehicleDetailsController.text.trim();

//       if (email.isEmpty || password.isEmpty || name.isEmpty || vehicleDetails.isEmpty) {
//         _showErrorDialog('Please fill in all required fields.');
//         return;
//       }

//       // Create user with Firebase Authentication
//       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       User? user = userCredential.user;

//       if (user != null) {
//         // Save user data in Firestore
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'email': email,
//           'role': 'delivery', // Set role as 'delivery'
//           'name': name,
//           'vehicleDetails': vehicleDetails,
//         });

//         // Show success dialog and redirect to Sign-In Screen
//         _showSuccessDialog('Registration successful! Please sign in.');
//       }
//     } catch (e) {
//       _showErrorDialog(e.toString());
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSuccessDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Success'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close the dialog
//               Navigator.pushReplacementNamed(context, '/gateway_screen'); // Navigate to Gateway Screen
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Delivery Registration'),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _vehicleDetailsController,
//               decoration: const InputDecoration(labelText: 'Vehicle Details'),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _businessNameController,
//               decoration: const InputDecoration(labelText: 'Business Name'),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'Password'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _handleSignUp,
//               child: const Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }