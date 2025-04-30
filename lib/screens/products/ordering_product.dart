    import 'package:flutter/material.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:firebase_auth/firebase_auth.dart';

    class OrderProductScreen extends StatefulWidget {
      final String productId;
      final String productName;
      final String sellerId;
      final double price;
      final String sellerName; // Already passed from the constructor

      // Constructor to accept the parameters
      const OrderProductScreen({
        Key? key,
        required this.productId,
        required this.productName,
        required this.sellerId,
        required this.price,
        required this.sellerName,  // No need to fetch sellerName from Firestore
      }) : super(key: key);

      @override
      State<OrderProductScreen> createState() => _OrderProductScreenState();
    }

    class _OrderProductScreenState extends State<OrderProductScreen> {
      late String whatsappNumber;
      int stockAvailable = 0;  // Initialize stockAvailable with a default value

      bool _isLoading = true;

      @override
      void initState() {
        super.initState();
        _fetchProductDetails(); // Only fetch the product details that are not passed in constructor
      }

      // Function to fetch product details
      Future<void> _fetchProductDetails() async {
        try {
          // Fetch product details, no need to fetch sellerName
          DocumentSnapshot productDoc =
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(widget.productId)
                  .get();
          
          // Get WhatsApp number and stock from the product document
          whatsappNumber = productDoc['whatsapp'] ?? 'No WhatsApp available';
          stockAvailable = productDoc['stock'] ?? 0;  // Default to 0 if stock is not found

          setState(() {
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          print('Error fetching product details: $e');
        }
      }

      // Function to place an order
      Future<void> _placeOrder(BuildContext context) async {
        try {
          // Get the current user (buyer)
          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            // If user is not logged in, show error
            return;
          }
          String buyerId = user.uid;
          String buyerName =
              user.displayName ?? 'Unknown Buyer'; // Default if no displayName

          // Get the current time as order date
          Timestamp orderDate = Timestamp.now();

          // Add the order to the Firestore 'orders' collection
          await FirebaseFirestore.instance.collection('orders').add({
            'productId': widget.productId,
            'productName': widget.productName,
            'price': widget.price,
            'buyerId': buyerId,
            'buyerName': buyerName,
            'sellerId': widget.sellerId,
            'orderDate': orderDate,
            'status': 'Ordered', // Set initial order status to 'Ordered'
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order placed for "${widget.productName}"!')),
          );
        } catch (e) {
          // Handle error
          print('Error placing order: $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
        }
      }

      // Function to show WhatsApp number in a dialog
      void _showWhatsAppNumber(BuildContext context) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Seller WhatsApp Number'),
              content: Text(whatsappNumber),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Order ${widget.productName}'),
            backgroundColor: Colors.black,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Name: ${widget.productName}',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Price: \$${widget.price.toString()}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Seller: ${widget.sellerName}', // No need to fetch sellerName from Firestore
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Stock Available: $stockAvailable',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => _placeOrder(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'Place Order',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showWhatsAppNumber(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'Show WhatsApp Number',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      }
    }
