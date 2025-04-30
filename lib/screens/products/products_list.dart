// In products_lists.dart (or whatever you named it)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shopping_cart_screen.dart'; // Import the new screen

class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;
  final String? sellerId; // Added sellerId

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.sellerId, // Make it optional during creation
  });
}

// In products_lists.dart

// ... (rest of the imports and CartItem definition)

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  List<CartItem> _cartItems = []; // Initialize the cart here

  Future<void> _addToCart(String productId, String productName, double price, int quantity) async {
    final existingItemIndex = _cartItems.indexWhere((item) => item.productId == productId);

    // Fetch the product document to get the sellerId
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(productId).get();
    final productData = productSnapshot.data() as Map<String, dynamic>?;
    final String? sellerId = productData?['sellerId']; // Assuming 'sellerId' field exists in your 'products' collection

    if (existingItemIndex != -1) {
      setState(() {
        _cartItems[existingItemIndex].quantity += quantity;
      });
    } else {
      setState(() {
        _cartItems.add(CartItem(
          productId: productId,
          name: productName,
          price: price,
          quantity: quantity,
          sellerId: sellerId, // Include the sellerId here
        ));
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $quantity of "$productName" to cart.')),
    );
  }

  void _showQuantityDialog(BuildContext context, String productId, String productName, double price) {
    TextEditingController quantityController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('How many "$productName" do you want to buy?'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                int quantity = int.tryParse(quantityController.text) ?? 1;
                if (quantity > 0) {
                  _addToCart(productId, productName, price, quantity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid quantity.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showWhatsAppDialog(BuildContext context, String whatsappNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seller WhatsApp Number'),
          content: Text(
            whatsappNumber.isNotEmpty ? whatsappNumber : 'Not available',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to navigate to the cart and receive updated items
  Future<void> _goToCart(BuildContext context) async {
    final updatedCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingCartScreen(cartItems: _cartItems),
      ),
    ) as List<CartItem>?; // Cast the result

    if (updatedCart != null) {
      setState(() {
        _cartItems = updatedCart; // Update the local cart with the result
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Products'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              _goToCart(context); // Use the new function
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').where('available', isEqualTo: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null) {
            return const Center(child: Text('No data received.')); // Or some other appropriate widget
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available yet.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              final String productId = document.id;
              final String name = data['name'] ?? 'No Name';
              final double price = (data['price'] ?? 0).toDouble();
              final String whatsapp = data['whatsapp'] ?? '';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('\$$price'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          _showQuantityDialog(context, productId, name, price);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add to Cart'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showWhatsAppDialog(context, whatsapp);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('WhatsApp'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                _goToCart(context); // Use the new function
              },
              label: Text('Go to Cart (${_cartItems.length})'),
              icon: const Icon(Icons.shopping_cart),
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }
}