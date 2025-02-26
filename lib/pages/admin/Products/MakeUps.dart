import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/keys.dart';

class ProductMakeUpCard extends StatefulWidget {
  const ProductMakeUpCard({super.key});

  @override
  State<ProductMakeUpCard> createState() => _ProductMakeUpCardState();
}

class _ProductMakeUpCardState extends State<ProductMakeUpCard> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final supabaseClient = SupabaseClient(SupaBaseuri, SupaBaseanonKey);
    final publicUrl =
        supabaseClient.storage.from('makeup').getPublicUrl(imagePath);
    return publicUrl;
  }

  Future<void> _deleteProduct(
      String productId, String imageUrl, String category) async {
    try {
      final imageName = imageUrl.split('/').last;
      await Supabase.instance.client.storage.from(category).remove([imageName]);
      await _firestore.collection(category).doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product and image deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void _showEditDialog(
    String productId,
    String currentName,
    double currentPrice,
    String category,
    Function(double) onUpdatePrice,
  ) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController priceController =
        TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newName = nameController.text;
              final newPrice = double.parse(priceController.text);
              _editProduct(productId, newName, newPrice, category);
              Navigator.of(context).pop();
              onUpdatePrice(newPrice);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _editProduct(
      String productId, String name, double price, String category) async {
    try {
      await _firestore.collection(category).doc(productId).update({
        'name': name,
        'price': price.toString(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product edited successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error editing product: $e');
    }
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
          // Safely access 'price' and provide a fallback if the field is missing
          var price =
              product['price'] ?? '0'; // Default to '0' if price is missing
          var priceValue = double.tryParse(price) ??
              0.0; // Ensure the price is a valid double
          String imageUrl = _getSupabaseImageUrl(product['imageUrl'] ?? '');

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
                  product['name'] ?? 'Unknown', // Safely access 'name'
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$$priceValue', // Display price safely
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(
                        product.id,
                        product['name'] ?? 'Unknown',
                        priceValue,
                        'makeup',
                        (newPrice) {},
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteProduct(product.id, imageUrl, 'makeup'),
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
}
