// import 'package:flutter/material.dart';
// import '../products/deliveries.dart'; // Import your deliveries screen file

// class DeliveryHomeScreen extends StatelessWidget {
//   final String name;

//   const DeliveryHomeScreen({Key? key, required this.name}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Welcome, $name'),
//         backgroundColor: Colors.black,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Hello Delivery Agent $name!', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const DeliveriesScreen()), // Navigate to DeliveriesScreen
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//               ),
//               child: const Text('Deliveries', style: TextStyle(fontSize: 20)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }