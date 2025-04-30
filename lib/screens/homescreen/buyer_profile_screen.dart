import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _vehicleInfoController = TextEditingController();
  TextEditingController _streetAddressController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();

  bool _isLoading = false;
  String? _userRole;
  String? _userId;
  bool _isEmailVerificationSent = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndRole();
  }

  Future<void> _loadUserProfileAndRole() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      _userId = user?.uid;
      if (user != null) {
        _emailController.text = user.email ?? '';
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          _userRole = userDoc['role'] as String?;
          if (_userRole == 'buyer') {
            DocumentSnapshot buyerDoc =
                await _firestore.collection('buyers').doc(user.uid).get();
            if (buyerDoc.exists && buyerDoc.data() != null) {
              _nameController.text = buyerDoc['name'] ?? '';
              _phoneController.text = buyerDoc['phone'] ?? '';
              if (buyerDoc['address'] != null && buyerDoc['address'] is Map) {
                _streetAddressController.text = buyerDoc['address']['street'] ?? '';
                _cityController.text = buyerDoc['address']['city'] ?? '';
                _stateController.text = buyerDoc['address']['state'] ?? '';
                _postalCodeController.text = buyerDoc['address']['postalCode'] ?? '';
              }
            }
          } else if (_userRole == 'seller') {
            DocumentSnapshot sellerDoc =
                await _firestore.collection('sellers').doc(user.uid).get();
            if (sellerDoc.exists && sellerDoc.data() != null) {
              _nameController.text = sellerDoc['contactName'] ?? '';
              _businessNameController.text = sellerDoc['businessName'] ?? '';
              _phoneController.text = sellerDoc['phone'] ?? '';
              // Add address fields for sellers if needed in the future
              if (sellerDoc['address'] != null &&
                  sellerDoc['address'] is Map) {
                _streetAddressController.text =
                    sellerDoc['address']['street'] ?? '';
                _cityController.text = sellerDoc['address']['city'] ?? '';
                _stateController.text = sellerDoc['address']['state'] ?? '';
                _postalCodeController.text =
                    sellerDoc['address']['postalCode'] ?? '';
              }
            }
          } else if (_userRole == 'delivery') {
            DocumentSnapshot deliveryDoc = await _firestore
                .collection('delivery_personnel')
                .doc(user.uid)
                .get();
            if (deliveryDoc.exists && deliveryDoc.data() != null) {
              _nameController.text = deliveryDoc['name'] ?? '';
              _phoneController.text = deliveryDoc['phone'] ?? '';
              _vehicleInfoController.text = deliveryDoc['vehicleInfo'] ?? '';
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User role not found.')),
          );
        }
      }
    } catch (error) {
      print('Error loading profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile information.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && _userRole != null) {
          final newName = _nameController.text.trim();
          final newEmail = _emailController.text.trim();
          bool emailChanged = user.email != newEmail;

          // Update user's name and potentially email in the 'users' collection
          await _firestore.collection('users').doc(user.uid).update({
            'displayName': newName,
            // 'email': newEmail, // Remove this line to prevent email updates here
          });

          // Update name and other role-specific fields in the respective collection
          if (_userRole == 'buyer') {
            final buyerRef = _firestore.collection('buyers').doc(user.uid);
            //Check if the document exists before updating.
            final docSnapshot = await buyerRef.get();
            if (docSnapshot.exists) {
              await buyerRef.update({
                'name': newName,
                'phone': _phoneController.text.trim(),
                'address': {
                  'street': _streetAddressController.text.trim(),
                  'city': _cityController.text.trim(),
                  'state': _stateController.text.trim(),
                  'postalCode': _postalCodeController.text.trim(),
                },
              });
            } else {
              // Create the document if it doesn't exist
              await buyerRef.set({
                'name': newName,
                'phone': _phoneController.text.trim(),
                'address': {
                  'street': _streetAddressController.text.trim(),
                  'city': _cityController.text.trim(),
                  'state': _stateController.text.trim(),
                  'postalCode': _postalCodeController.text.trim(),
                },
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Buyer document did not exist, so it was created.')),
              );
            }
          } else if (_userRole == 'seller') {
            final sellerRef = _firestore.collection('sellers').doc(user.uid);
            final docSnapshot = await sellerRef.get();
            if (docSnapshot.exists) {
              await sellerRef.update({
                'contactName': newName,
                'businessName': _businessNameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'address': {
                  //added seller address
                  'street': _streetAddressController.text.trim(),
                  'city': _cityController.text.trim(),
                  'state': _stateController.text.trim(),
                  'postalCode': _postalCodeController.text.trim(),
                },
              });
            } else {
              // Create the document if it doesn't exist
              await sellerRef.set({
                'contactName': newName,
                'businessName': _businessNameController.text.trim(),
                'phone': _phoneController.text.trim(),
                'address': {
                  'street': _streetAddressController.text.trim(),
                  'city': _cityController.text.trim(),
                  'state': _stateController.text.trim(),
                  'postalCode': _postalCodeController.text.trim(),
                },
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Seller document did not exist, so it was created.')),
              );
            }
          } else if (_userRole == 'delivery') {
            await _firestore
                .collection('delivery_personnel')
                .doc(user.uid)
                .update({
              'name': newName,
              'phone': _phoneController.text.trim(),
              'vehicleInfo': _vehicleInfoController.text.trim(),
            });
          }

          // Update email in Firebase Auth
          if (emailChanged && _userRole != 'buyer' && _userRole != 'seller') {
            // Allow email change only for non-buyer/seller
            try {
              await user.updateEmail(newEmail);
              setState(() {
                _isEmailVerificationSent = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Email updated. Please verify your new email address.'),
                ),
              );
            } on FirebaseAuthException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update email: ${e.message}')),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailChanged
                  ? 'Profile updated successfully (new email requires verification).'
                  : 'Profile updated successfully.'),
            ),
          );
        }
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.message}')),
        );
      } catch (error) {
        print('Error saving profile: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Name', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    if (_userRole == 'seller') ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                            labelText: 'Business Name',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your business name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Business Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _streetAddressController,
                        decoration: const InputDecoration(
                            labelText: 'Street Address',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your street address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                            labelText: 'City', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                            labelText: 'State', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your state';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your postal code';
                          }
                          if (value.length < 5) {
                            return 'Please enter a valid postal code';
                          }
                          return null;
                        },
                      ),
                    ] else if (_userRole == 'buyer') ...[
                      //buyer form fields
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Delivery Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _streetAddressController,
                        decoration: const InputDecoration(
                            labelText: 'Street Address',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your street address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                            labelText: 'City', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                            labelText: 'State', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your state';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your postal code';
                          }
                          if (value.length < 5) {
                            return 'Please enter a valid postal code';
                          }
                          return null;
                        },
                      ),
                    ] else if (_userRole == 'delivery') ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _vehicleInfoController,
                        decoration: const InputDecoration(
                            labelText: 'Vehicle Information',
                            border: OutlineInputBorder()),
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save Profile',
                              style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 10),
                    if (_userRole == 'buyer' || _userRole == 'seller')
                      const Text(
                        "Please contact admin for changing email address and password",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

  