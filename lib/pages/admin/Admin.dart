import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:web_application/constants/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_application/pages/admin/Products/MakeUps.dart';
import 'package:web_application/pages/admin/Products/Weaves.dart';
import 'package:web_application/pages/home_page.dart';
import 'package:web_application/widgets/adminheader.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

  // Controllers for adding/editing products
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _inchController = TextEditingController();
  Map<String, String> _prices = {};

  XFile? _selectedImage;
  String? _selectedCategory;

  Future<void> _pickImageAndAddProduct() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _selectedCategory = 'weaves'; // Automatically set to 'weaves'
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _inchController,
                  decoration: const InputDecoration(labelText: 'Inch'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _prices[_inchController.text] = _priceController.text;
                      _inchController.clear();
                      _priceController.clear();
                    });
                  },
                  child: const Text('Add Inch and Price'),
                ),
                ..._prices.entries.map((entry) {
                  return Text('${entry.key}: \$${entry.value}');
                }),
                const SizedBox(height: 10),
                _selectedImage != null
                    ? (kIsWeb
                        ? Image.network(_selectedImage!.path)
                        : Image.file(File(_selectedImage!.path)))
                    : Container(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _prices.isNotEmpty) {
                  _addProduct(
                    _nameController.text,
                    _prices,
                    _selectedImage!,
                    _selectedCategory!,
                  );
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel and close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      print("No image selected");
    }
  }

  Future<void> _addProduct(String name, Map<String, String> prices, XFile image,
      String category) async {
    try {
      String imageUrl;
      if (kIsWeb) {
        Uint8List imageData = await image.readAsBytes();
        final response =
            await supabase.SupabaseClient(SupaBaseuri, SupaBaseanonKey)
                .storage
                .from(category)
                .uploadBinary(image.name, imageData);
        print('Upload response (web): $response');
        imageUrl = supabase.SupabaseClient(SupaBaseuri, SupaBaseanonKey)
            .storage
            .from(category)
            .getPublicUrl(image.name);
        print('Public URL (web): $imageUrl');
      } else {
        final fileBytes = await image.readAsBytes();
        final response =
            await supabase.SupabaseClient(SupaBaseuri, SupaBaseanonKey)
                .storage
                .from(category)
                .uploadBinary(image.name, fileBytes);
        print('Upload response (mobile): $response');
        imageUrl = supabase.SupabaseClient(SupaBaseuri, SupaBaseanonKey)
            .storage
            .from(category)
            .getPublicUrl(image.name);
        print('Public URL (mobile): $imageUrl');
      }
      await FirebaseFirestore.instance.collection(category).add({
        'name': name,
        'prices': prices,
        'imageUrl': imageUrl,
      });
      _nameController.clear();
      _priceController.clear();
      _inchController.clear();
      setState(() {
        _selectedImage = null;
        _selectedCategory = null;
        _prices = {};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> _pickImageAndAddMakeUp() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _selectedCategory = 'makeup'; // Assigning the category to makeup
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Product Price'),
                  keyboardType: TextInputType.number,
                ),
                _selectedImage != null
                    ? (kIsWeb
                        ? Image.network(_selectedImage!.path)
                        : Image.file(File(_selectedImage!.path)))
                    : Container(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _priceController.text.isNotEmpty) {
                  _addMakeUp(
                    _nameController.text,
                    _priceController.text,
                    _selectedImage!,
                    _selectedCategory!,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
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
    } else {
      print("No image selected");
    }
  }

  Future<void> _addMakeUp(
      String name, String price, XFile image, String category) async {
    try {
      String imagePath;
      if (kIsWeb) {
        Uint8List imageData = await image.readAsBytes();
        final response =
            await supabase.SupabaseClient(SupaBaseuri, SupaBaseanonKey)
                .storage
                .from(category)
                .uploadBinary(image.name, imageData);
        print('Upload response (web): $response');
        imagePath = image.name; // Store only the path
        print('Stored Image Path (web): $imagePath');
      } else {
        final fileBytes = await image.readAsBytes();
        final response =
            await supabase.SupabaseClient(SupaBaseuri, SupaBaseanonKey)
                .storage
                .from(category)
                .uploadBinary(image.name, fileBytes);
        print('Upload response (mobile): $response');
        imagePath = image.name; // Store only the path
        print('Stored Image Path (mobile): $imagePath');
      }
      await _firestore.collection(category).add({
        'name': name,
        'price': price, // Ensure price is correctly stored as a single field
        'imageUrl': imagePath, // Store only the path
      });
      _nameController.clear();
      _priceController.clear();
      setState(() {
        _selectedImage = null;
        _selectedCategory = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding product: $e');
    }
  }

// Function to delete a product
  Future<void> _deleteProduct(
      String productId, String imageUrl, String category) async {
    try {
      // Get the image name from the imageUrl
      final imageName = imageUrl.split('/').last;

      // Delete the image from Supabase storage
      await Supabase.instance.client.storage.from(category).remove([imageName]);

      // Delete the product details from Firebase
      await _firestore.collection(category).doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product and image deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      print('Product and image deleted successfully!');
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void _showEditDialog(
      String productId,
      String currentName,
      double currentPrice,
      String category,
      Map<String, String> prices,
      String selectedInch,
      Function(String, double) onUpdatePrice) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController priceController =
        TextEditingController(text: currentPrice.toString());
    String? _selectedInch = selectedInch;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$_selectedInch"',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
              _editProduct(
                  productId, newName, newPrice, category, _selectedInch);
              Navigator.of(context).pop();
              setState(() {
                _prices[productId] = priceController.text;
              });
              onUpdatePrice(_selectedInch, newPrice);
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

  // Function to edit a product

  Future<void> _editProduct(String productId, String name, double price,
      String category, String inch) async {
    try {
      await _firestore.collection(category).doc(productId).update({
        'name': name,
        'prices.$inch': price.toString(), // Ensure price is stored as a string
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

  Future<void> logoutAdmin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAdminLoggedIn'); // Clear admin login state
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const HomePage()), // Redirect to HomePage
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AdminHeader(
                onNavMenuTap: () async {
                  await logoutAdmin(context);
                },
              ),
              const SizedBox(height: 20),
              _buildCategorySection('Weaves', 'weaves', context),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImageAndAddProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Add Weaves'),
              ),
              const SizedBox(height: 20),
              _buildCategorySection('Makeup', 'makeup', context),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImageAndAddMakeUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Add Makeup'),
              ),
              const SizedBox(height: 20),
              _buildBookingSection(context),
              const SizedBox(height: 20),
              _buildMessagesSection(context),
              const SizedBox(height: 20),
              _buildPaidOrdersSection(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      String title, String collection, BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      children: [
        if (title == "weaves" || title == "Weaves")
          _buildProductStreamBuilder(collection, context),
        if (title == "makeup" || title == "Makeup") ProductMakeUpCard(),
      ],
    );
  }

  Widget _buildProductStreamBuilder(String collection, BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final ScrollController _scrollController = ScrollController();

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

    return StreamBuilder(
      stream: _firestore.collection(collection).orderBy('name').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var products = snapshot.data!.docs;
        List<Widget> productWidgets = products.map<Widget>((product) {
          Map<String, String>? prices;
          var productData = product.data() as Map<String, dynamic>;

          if (productData.containsKey('prices')) {
            prices = Map<String, String>.from(productData['prices']);
          } else {
            prices = {};
          }

          return ProductCard(
            productId: product.id,
            img: productData['imageUrl'] ?? '',
            title: productData['name'],
            prices: prices,
            category: collection,
            onAddToCart: (productDetails) {
              // Handle adding to cart
            },
            onDelete: _deleteProduct,
            onEdit: (String productId,
                String currentName,
                double currentPrice,
                String category,
                Map<String, String> prices,
                String selectedInch,
                Function(String, double) onUpdatePrice) {
              _showEditDialog(
                productId,
                currentName,
                currentPrice,
                category,
                prices,
                selectedInch,
                onUpdatePrice,
              );
            },
            currentPrice:
                double.parse(prices.isNotEmpty ? prices.values.first : '0'),
          );
        }).toList();

        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _scrollLeft,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Row(children: productWidgets),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _scrollRight,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingSection(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Bookings',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      children: [
        _buildBookingStreamBuilder(context),
      ],
    );
  }

  Widget _buildBookingStreamBuilder(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var bookings = snapshot.data!.docs;
        List<Widget> bookingWidgets = bookings.map<Widget>((booking) {
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: ListTile(
              title: Text(
                'Booked Day: ${booking['date']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList();
        return Column(children: bookingWidgets);
      },
    );
  }

  Widget _buildMessagesSection(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Contact Us Messages',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      children: [
        _buildMessagesStreamBuilder(context),
      ],
    );
  }

  Widget _buildMessagesStreamBuilder(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('contacts')
          .orderBy('timestamp', descending: true) // Sort by most recent
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No messages yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        List<Widget> messageWidgets = messages.map<Widget>((message) {
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: ListTile(
              title: Text(
                message['name'] ?? 'Unknown Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject: ${message['subject'] ?? 'No Subject'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(message['message'] ?? 'No Message'),
                ],
              ),
              trailing: Text(
                message['email'] ?? 'No Email',
                style: const TextStyle(fontSize: 12, color: Colors.teal),
              ),
            ),
          );
        }).toList();

        return Column(children: messageWidgets);
      },
    );
  }

  Widget _buildPaidOrdersSection(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Paid Orders',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      children: [
        _buildPaidOrdersStreamBuilder(context),
      ],
    );
  }

  Widget _buildPaidOrdersStreamBuilder(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('cart')
          .where('status', isEqualTo: 'paid') // Fetch only paid orders
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var orders = snapshot.data!.docs;

        List<Widget> orderWidgets = orders.map<Widget>((order) {
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: ListTile(
              title: Text(
                'Product: ${order['productName']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Customer: ${order['name']}\n'
                'Installation Date: ${order['installationDay']}\n'
                'Price: \$${order['price']}',
              ),
            ),
          );
        }).toList();
        return Column(children: orderWidgets);
      },
    );
  }
}
