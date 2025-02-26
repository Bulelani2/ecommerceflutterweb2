import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_application/Database/Cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _cvvController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _bankNameController.clear();
    _accountNumberController.clear();
    _accountHolderController.clear();
    _cvvController.clear();
    _expiryDateController.clear();
  }

  void showErrorDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.green),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> processPayment(String amount) async {
    if (_formKey.currentState!.validate()) {
      try {
        User user = _auth.currentUser!;

        // Add payment record
        await _firestore.collection('payments').add({
          'user_id': user.uid,
          'amount': double.parse(amount),
          'bank_name': _bankNameController.text,
          'account_number': _accountNumberController.text,
          'account_holder': _accountHolderController.text,
          'cvv': _cvvController.text,
          'expiry_date': _expiryDateController.text,
          'timestamp': Timestamp.now(),
          'status': 'completed',
        });

        // Update all cart items for this user to "paid"
        QuerySnapshot cartItems = await _firestore
            .collection('cart')
            .where('user_id', isEqualTo: user.uid)
            .where('status', isEqualTo: 'pending')
            .get();

        for (var doc in cartItems.docs) {
          await _firestore.collection('cart').doc(doc.id).update({
            'status': 'paid',
          });
        }

        showSuccessDialog('Payment processed successfully');
        print('Payment processed successfully');
      } catch (e) {
        print('Payment failed: $e');
        showErrorDialog("Payment failed. Please try again.");
      }
    }
  }

  void _showBankDetailsDialog(BuildContext context, String amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Bank Details'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  _buildTextField(
                    controller: _accountNumberController,
                    label: 'Account Number',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      } else if (value.length < 6 || value.length > 20) {
                        return 'Must be 6-20 digits';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _accountHolderController,
                    label: 'Account Holder Name',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  _buildTextField(
                    controller: _cvvController,
                    label: 'CVV',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.length == 3 ? null : 'Must be 3 digits',
                  ),
                  _buildTextField(
                    controller: _expiryDateController,
                    label: 'Expiry Date (MM/YY)',
                    keyboardType: TextInputType.datetime,
                    validator: (value) =>
                        RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$')
                                .hasMatch(value!)
                            ? null
                            : 'Invalid format',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await processPayment(amount);
                  showSuccessDialog('Payment processed successfully');
                  Navigator.of(context).pop();
                  _clearFields();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final totalPrice = context.watch<CartProvider>().getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("Your cart is empty!"))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final title = item['title'] as String?;
                      final img = item['img'] as String?;
                      final price = item['price'] as String?;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: img != null
                              ? Image.network(
                                  img,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(title ?? "Unknown product"),
                          subtitle:
                              Text(price != null ? "\$$price" : "No price"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context
                                  .read<CartProvider>()
                                  .removeFromCart(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total: ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (cart.isEmpty) {
                      showErrorDialog("Your cart is empty.");
                    } else {
                      _showBankDetailsDialog(
                          context, totalPrice.toStringAsFixed(2));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Proceed to Checkout",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
