import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({Key? key}) : super(key: key);

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  // Removed address controllers
  // TextEditingController _streetAddressController = TextEditingController();
  // TextEditingController _cityController = TextEditingController();
  // TextEditingController _stateController = TextEditingController();
  // TextEditingController _postalCodeController = TextEditingController();

  bool _isLoading = false;
  String? _userRole;
  String? _userId;
  bool _isEditing = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndRole();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    // Removed address controllers
    // _streetAddressController.dispose();
    // _cityController.dispose();
    // _stateController.dispose();
    // _postalCodeController.dispose();
    super.dispose();
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
          if (_userRole == 'seller') {
            DocumentSnapshot sellerDoc =
                await _firestore.collection('sellers').doc(user.uid).get();
            if (sellerDoc.exists && sellerDoc.data() != null) {
              _nameController.text = sellerDoc['contactName'] ?? '';
              _businessNameController.text = sellerDoc['businessName'] ?? '';
              _phoneController.text = sellerDoc['phone'] ?? '';
              // Removed address loading
              // if (sellerDoc['address'] != null &&
              //     sellerDoc['address'] is Map) {
              //   _streetAddressController.text =
              //       sellerDoc['address']['street'] ?? '';
              //   _cityController.text = sellerDoc['address']['city'] ?? '';
              //   _stateController.text = sellerDoc['address']['state'] ?? '';
              //   _postalCodeController.text =
              //       sellerDoc['address']['postalCode'] ?? '';
              // }
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
        const SnackBar(
            content: Text('Failed to load profile information.')),
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
      if (user != null && _userRole == 'seller') {
        final newName = _nameController.text.trim();
        final newEmail = _emailController.text.trim();
        final newBusinessName = _businessNameController.text.trim();
        final newPhone = _phoneController.text.trim();
        // Removed address variables
        // final newStreet = _streetAddressController.text.trim();
        // final newCity = _cityController.text.trim();
        // final newState = _stateController.text.trim();
        // final newPostalCode = _postalCodeController.text.trim();

        // Update user's name in the 'users' collection
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': newName,
        });

        // Update or create seller data in the 'sellers' collection
        final sellerRef = _firestore.collection('sellers').doc(user.uid);
        final docSnapshot = await sellerRef.get();
        if (docSnapshot.exists) {
          await sellerRef.update({
            'contactName': newName,
            'businessName': newBusinessName,
            'phone': newPhone,
            // Removed address update
            // 'address': {
            //   'street': newStreet,
            //   'city': newCity,
            //   'state': newState,
            //   'postalCode': newPostalCode,
            // },
          });
        } else {
          await sellerRef.set({
            'contactName': newName,
            'businessName': newBusinessName,
            'phone': newPhone,
            // Removed address set
            // 'address': {
            //   'street': newStreet,
            //   'city': newCity,
            //   'state': newState,
            //   'postalCode': newPostalCode,
            // },
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Seller document did not exist, so it was created.')),
          );
        }

        //update email
        if (user.email != newEmail) {
          try {
            await user.updateEmail(newEmail);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Email updated. Please verify your new email address.')),
            );
          } on FirebaseAuthException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to update email: ${e.message}')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        setState(() {
          _isEditing = false;
        });
         _loadUserProfileAndRole();
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.message}')),
      );
    } catch (error) {
      print('Error saving profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to update profile. Please try again.')),
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
        title: const Text('Seller Profile'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: _isEditing ? const Icon(Icons.cancel) : const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                 if (!_isEditing) {
                   _loadUserProfileAndRole();
                }
              });
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
                    Text(
                      _isEditing ? 'Edit Profile' : 'My Profile',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Contact Name',
                          border: OutlineInputBorder()),
                      enabled: _isEditing,
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
                      enabled: _isEditing,
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                          labelText: 'Business Name',
                          border: OutlineInputBorder()),
                      enabled: _isEditing,
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
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    // Removed Address section
                    // const SizedBox(height: 20),
                    // const Text(
                    //   'Business Address',
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 10),
                    // TextFormField(
                    //   controller: _streetAddressController,
                    //   decoration: const InputDecoration(
                    //       labelText: 'Street Address',
                    //       border: OutlineInputBorder()),
                    //   enabled: _isEditing,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter your street address';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 10),
                    // TextFormField(
                    //   controller: _cityController,
                    //   decoration: const InputDecoration(
                    //       labelText: 'City', border: OutlineInputBorder()),
                    //   enabled: _isEditing,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter your city';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 10),
                    // TextFormField(
                    //   controller: _stateController,
                    //   decoration: const InputDecoration(
                    //       labelText: 'State', border: OutlineInputBorder()),
                    //   enabled: _isEditing,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter your state';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    //  const SizedBox(height: 10),
                    // TextFormField(
                    //   controller: _postalCodeController,
                    //   decoration: const InputDecoration(
                    //       labelText: 'Postal Code',
                    //       border: OutlineInputBorder()),
                    //   keyboardType: TextInputType.number,
                    //   enabled: _isEditing,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter your postal code';
                    //     }
                    //     if (value.length < 5) {
                    //       return 'Please enter a valid postal code';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isEditing ? _saveProfile : null,
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
                          : Text(
                              _isEditing ? 'Save Profile' : 'Edit Profile',
                              style: const TextStyle(fontSize: 18)),
                    ),
                    if (!_isEditing) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Implement your forgot password logic here
                            // For example:
                            // Navigator.pushNamed(context, '/forgot_password');
                            print("Forgot Password/Email Pressed");
                          },
                          child: const Text(
                            "Forgot Password or Email?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

