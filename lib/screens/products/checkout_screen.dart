import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'products_list.dart'; // Import for CartItem
import '../homescreen/buyer_homescreen.dart'; // Assuming this is your buyer's home screen

class CheckScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckScreen({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '+91'); // Default to India's country code

  Future<void> _placeOrder(BuildContext context) async {
    String? buyerId = FirebaseAuth.instance.currentUser?.uid;
    if (buyerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to place an order.')),
      );
      return;
    }

    final String deliveryAddress = _addressController.text.trim();
    final String phoneNumber = _phoneController.text.trim();
    final String countryCode = _countryCodeController.text.trim();
    final String fullPhoneNumber = '$countryCode$phoneNumber';

    if (deliveryAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your delivery address.')),
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    if (countryCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the country code.')),
      );
      return;
    }

    // Fetch the buyer's document to get their name
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(buyerId).get();

    String? buyerName;
    if (userSnapshot.exists && userSnapshot.data() != null) {
      buyerName = userSnapshot.data()!['name']; // Assuming 'name' field in users collection
    } else {
      buyerName = 'Unknown Buyer'; // Fallback if buyer data not found
    }

    CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    try {
      String? sellerIdOfOrder = widget.cartItems.isNotEmpty ? widget.cartItems.first.sellerId : null;

      await orders.add({
        'buyerId': buyerId,
        'buyerName': buyerName, // Add the buyer's name here
        'orderItems': widget.cartItems.map((item) => {
              'productId': item.productId,
              'name': item.name,
              'price': item.price,
              'quantity': item.quantity,
              'sellerId': item.sellerId,
            }).toList(),
        'totalAmount': widget.totalAmount,
        'deliveryAddress': deliveryAddress,
        'phoneNumber': fullPhoneNumber, // Store the full phone number
        'countryCode': countryCode, // You can store the country code separately if needed
        'paymentMethod': 'Cash on Delivery',
        'orderStatus': 'Pending',
        'orderDate': DateTime.now(),
        'sellerId': sellerIdOfOrder,
      });

      // Optionally clear the cart
      // Navigate to the buyer's home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BuyerHomeScreen(name: buyerName ?? 'Guest')), // Use null-aware operator
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (error) {
      print('Error placing order: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Order'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Your Order',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('${item.name} x ${item.quantity} - \$${(item.price * item.quantity).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _countryCodeController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Country Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 7,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _placeOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Place Order (Cash on Delivery)', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}