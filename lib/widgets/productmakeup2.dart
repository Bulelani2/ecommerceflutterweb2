import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as users;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_application/constants/keys.dart';
import 'package:web_application/pages/Login_page.dart';
import '../Database/Cart_provider.dart';
import '../constants/colors.dart';

class ProductmakeupCard2 extends StatefulWidget {
  const ProductmakeupCard2({super.key});

  @override
  State<ProductmakeupCard2> createState() => _ProductmakeupCard2State();
}

class _ProductmakeupCard2State extends State<ProductmakeupCard2> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Supabase client for fetching images
  final supabaseClient = SupabaseClient(SupaBaseuri, SupaBaseanonKey);

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.position.pixels - 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.position.pixels + 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  String _getSupabaseImageUrl(String imagePath) {
    final publicUrl =
        supabaseClient.storage.from('makeup').getPublicUrl(imagePath);
    return publicUrl;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: _buildMakeUpStreamBuilder(context),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMakeUpStreamBuilder(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('makeup').orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var products = snapshot.data!.docs;
        List<Widget> productWidgets = products.map<Widget>((product) {
          String price = product['price'];
          String imagePath = product['imageUrl']; // Image path from Firestore

          // Get public image URL from Supabase
          String imageUrl = _getSupabaseImageUrl(imagePath);

          return Container(
            margin: const EdgeInsets.only(left: 40),
            clipBehavior: Clip.antiAlias,
            height: 320,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColor.bgdark1,
            ),
            child: Column(
              children: [
                Image.network(
                  alignment: Alignment.center,
                  imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 250,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.error),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          _showLoginDialog(context);
                        } else {
                          // Ensure fresh user authentication
                          await user.reload();
                          if (FirebaseAuth.instance.currentUser != null) {
                            _showUserDetailsDialog(context, product, imageUrl);
                          } else {
                            _showLoginDialog(context);
                          }
                        }
                      },
                      child: const Text("Add to Cart"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        }).toList();
        return Row(children: productWidgets);
      },
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please login to add items to your cart."),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text("Login"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserDetailsDialog(
      BuildContext context, dynamic product, String imageUrl) {
    final TextEditingController _nameController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Your Name"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: const Text("Select Day"),
              ),
              if (selectedDate != null)
                Text(
                    "Selected Day: ${DateFormat('yMMMd').format(selectedDate!)}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && selectedDate != null) {
                  // Check if user is logged in BEFORE adding to cart
                  users.User? user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    Navigator.of(context).pop(); // Close dialog first
                    _showLoginDialog(context); // Show login prompt
                    return; // Stop further execution
                  }

                  final cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  cartProvider.addToCart({
                    'title': product['name'],
                    'img': imageUrl,
                    'price': product['price'],
                  }, context);

                  _addToCart(
                    context,
                    product,
                    imageUrl,
                    _nameController.text,
                    selectedDate!,
                  );

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all details")),
                  );
                }
              },
              child: const Text("Add to Cart"),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(BuildContext context, dynamic product, String imageUrl,
      String name, DateTime date) {
    users.User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showLoginDialog(context); // Show login prompt
      return;
    }
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    _firestore.collection('cart').add({
      'user_id': user.uid,
      'name': name,
      'installationDay': formattedDate,
      'productName': product['name'],
      'price': product['price'],
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item added to cart successfully!")),
    );
  }
}
