// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:web_application/constants/products.dart';
// import 'package:web_application/pages/Login_page.dart';

// import '../constants/colors.dart';

// class ProductFrontalCards2 extends StatefulWidget {
//   const ProductFrontalCards2({super.key, required this.onAddToCart});
//   final Function(Map<String, String>) onAddToCart;
//   @override
//   State<ProductFrontalCards2> createState() => _ProductFrontalCards2State();
// }

// class _ProductFrontalCards2State extends State<ProductFrontalCards2> {
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final screenWidth = screenSize.width;
//     return Container(
//       width: screenWidth,
//       padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             for (int i = 0; i < productsfrontalItems.length; i++)
//               ProductCard(
//                 img: productsfrontalItems[i]["img"],
//                 title: productsfrontalItems[i]["title"],
//                 prices:
//                     productsfrontalItems[i]["prices"] as Map<String, String>,
//                 onAddToCart: widget.onAddToCart,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ProductCard extends StatefulWidget {
//   final String img;
//   final String title;
//   final Map<String, String> prices;
//   final Function(Map<String, String>) onAddToCart;
//   const ProductCard({
//     required this.img,
//     required this.title,
//     required this.prices,
//     super.key,
//     required this.onAddToCart,
//   });

//   @override
//   _ProductCardState createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   String? _selectedInch;
//   String _price = "";

//   @override
//   void initState() {
//     super.initState();
//     _price = widget.prices.values.first; // Set initial price
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(left: 40),
//       clipBehavior: Clip.antiAlias,
//       height: 400,
//       width: 250,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: CustomColor.bgdark1,
//       ),
//       child: Column(
//         children: [
//           Image.asset(
//             alignment: Alignment.center,
//             widget.img,
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Text(
//             widget.title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Text(
//             _price,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Material(
//             child: DropdownButton<String>(
//               isExpanded: true,
//               value: _selectedInch,
//               hint: const Text('10"'),
//               items: widget.prices.keys.map((String val) {
//                 return DropdownMenuItem<String>(
//                   value: val,
//                   child: Text(val),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedInch = newValue;
//                   _price = widget.prices[newValue!]!;
//                 });
//               },
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               OutlinedButton(
//                 style: ButtonStyle(
//                   backgroundColor: WidgetStateProperty.resolveWith<Color>(
//                     (states) {
//                       if (states.contains(WidgetState.hovered)) {
//                         return CustomColor.bgdark2;
//                       }
//                       return Colors.transparent;
//                     },
//                   ),
//                   overlayColor: WidgetStateProperty.resolveWith<Color>(
//                     (states) {
//                       if (states.contains(WidgetState.pressed)) {
//                         return CustomColor.blendColor;
//                       }
//                       return Colors.transparent;
//                     },
//                   ),
//                 ),
//                 onPressed: () {
//                   final User? user = FirebaseAuth.instance.currentUser;
//                   if (user == null) {
//                     _showLoginDialog(context);
//                   } else {
//                     // Call the onAddToCart function to add the product to cart and Firestore
//                     widget.onAddToCart({
//                       'img': widget.img,
//                       'title': widget.title,
//                       'price': _price,
//                     });
//                   }
//                 },
//                 child: const Text("Buy Now"),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDialog(Widget img, Widget text) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return CupertinoAlertDialog(
//               title: img,
//               content: text,
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text("Back"),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: IconButton(
//                     icon: const Icon(Icons.shopping_cart_checkout),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showLoginDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoAlertDialog(
//           title: const Text("Login Required"),
//           content: const Text("Please login to make a purchase."),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const LoginPage(),
//                       ));
//                   // Navigate to login page or show login form
//                 },
//                 child: const Text("Login"),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text("Cancel"),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/keys.dart';
import 'package:web_application/pages/Login_page.dart';

class ProductFrontalCards2 extends StatefulWidget {
  const ProductFrontalCards2({super.key, required this.onAddToCart});
  final Function(Map<String, String>) onAddToCart;

  @override
  State<ProductFrontalCards2> createState() => _ProductFrontalCards2State();
}

class _ProductFrontalCards2State extends State<ProductFrontalCards2> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    if (_scrollController.position.pixels > 0) {
      _scrollController.animateTo(
        _scrollController.position.pixels - 300,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent) {
      _scrollController.animateTo(
        _scrollController.position.pixels + 300,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Same helper function to fetch Supabase image URL
  String _getSupabaseImageUrl(String imagePath) {
    final supabaseClient = SupabaseClient(SupaBaseuri, SupaBaseanonKey);
    try {
      // ignore: unused_local_variable
      final publicUrl =
          supabaseClient.storage.from('weaves').getPublicUrl(imagePath);
      return imagePath;
    } catch (e) {
      print('Error fetching image URL: $e');
      return ''; // Return an empty string or a placeholder image URL in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _scrollLeft,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('weaves').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var products = snapshot.data!.docs;
                  return Row(
                    children: products.map((product) {
                      final imageUrl =
                          _getSupabaseImageUrl(product['imageUrl']);
                      final prices = Map<String, String>.from(
                        product['prices'] as Map<String, dynamic>,
                      );

                      return ProductCard(
                        imgPath: imageUrl,
                        title: product['name'],
                        prices: prices,
                        onAddToCart: widget.onAddToCart,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _scrollRight,
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String imgPath;
  final String title;
  final Map<String, String> prices;
  final Function(Map<String, String>) onAddToCart;

  const ProductCard({
    required this.imgPath,
    required this.title,
    required this.prices,
    required this.onAddToCart,
    super.key,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String? _selectedInch;
  late String _price;

  @override
  void initState() {
    super.initState();
    _price = widget.prices.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40),
      clipBehavior: Clip.antiAlias,
      height: 400,
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CustomColor.bgdark1,
      ),
      child: Column(
        children: [
          Image.network(
            widget.imgPath,
            width: 250,
            height: 200,
            fit: BoxFit.cover,
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
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '\$$_price',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedInch,
            hint: const Text('Select Size'),
            items: widget.prices.keys.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedInch = newValue;
                _price = widget.prices[newValue!]!;
              });
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                _showLoginDialog(context);
              } else if (_selectedInch == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Please select a size before adding to cart.')),
                );
              } else {
                widget.onAddToCart({
                  'img': widget.imgPath,
                  'title': widget.title,
                  'price': _price,
                });
              }
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please login to make a purchase."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
