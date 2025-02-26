import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/keys.dart';
import 'package:web_application/pages/Login_page.dart';
import 'package:web_application/widgets/aboutus.dart';
import 'package:web_application/widgets/contactus.dart';
import 'package:web_application/widgets/footer.dart';
import 'package:web_application/widgets/productmakeup.dart';
import 'package:web_application/widgets/productmakeup2.dart';
import 'package:web_application/widgets/productsfrontal.dart';
import 'package:web_application/widgets/drawer.dart';
import 'package:web_application/widgets/header.dart';
import 'package:web_application/widgets/intro.dart';
import 'package:web_application/widgets/productsfrontal2.dart';
import 'package:web_application/widgets/sec_header.dart';
import 'package:web_application/widgets/sec_intro.dart';

import '../widgets/aboutus2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = []; // Search results

  final List<GlobalKey> navbarKeys = List.generate(4, (index) => GlobalKey());
  DateTime today = DateTime.now();
  var selectedDay = DateFormat("E, dd-MM-yyyy");

  void _onDayselected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  Future<void> uploadBookings() async {
    try {
      await FirebaseFirestore.instance.collection("bookings").add(
        {
          "date": selectedDay.format(today).toString(),
        },
      );
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text(
              "Success",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ));
                  },
                  child: const Text("Continue"),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              e.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ));
                  },
                  child: const Text("Continue"),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            "Do you want to proceed",
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
          content: Text(
            selectedDay.format(today),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () async {
                  await uploadBookings();
                },
                child: const Text("Yes"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Back"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      // Fetch Weaves Products
      final weavesQuery = await FirebaseFirestore.instance
          .collection('weaves')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Fetch Makeup Products
      final makeupQuery = await FirebaseFirestore.instance
          .collection('makeup')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      setState(() {
        _searchResults = [
          ...weavesQuery.docs,
          ...makeupQuery.docs,
        ];
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  final ScrollController _scrollController = ScrollController();
  // Supabase client for fetching images
  final supabaseClient = SupabaseClient(SupaBaseuri, SupaBaseanonKey);
  String _getSupabaseImageUrl(String imagePath) {
    final publicUrl =
        supabaseClient.storage.from('makeup').getPublicUrl(imagePath);
    return publicUrl;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: CustomColor.bgdark1,
          endDrawer: constraints.maxWidth >= 685.0
              ? null
              : DrawerMobile(
                  onNavItemTap: (int navIndex) {
                    //call function
                    scaffoldKey.currentState?.closeEndDrawer();
                    scrollToSection(navIndex);
                  },
                ),
          body: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(
                  key: navbarKeys.first,
                ),
                //MAIN
                if (constraints.maxWidth >= 685.0)
                  Header(
                    onNavMenuTap: (int navIndex) {
                      //call function
                      scrollToSection(navIndex);
                    },
                  )
                else
                  SecHeader(
                    onMenuTap: () {
                      scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),

                if (constraints.maxWidth >= 981.0)
                  const Intro()
                else
                  const Sec_Intro(),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Container(
                      width: 400, // Set the desired width for the search bar
                      decoration: BoxDecoration(
                        color: CustomColor.bgdark1,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for products...',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onChanged: (value) {
                          _searchProducts(value); // Real-time search
                        },
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),

                // Displaying search results
                _searchResults.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                _scrollController.animateTo(
                                  _scrollController.offset - 200,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: Row(
                                  children: _searchResults.map((productDoc) {
                                    var product = productDoc.data()
                                        as Map<String, dynamic>;
                                    String collectionName =
                                        productDoc.reference.parent.id;
                                    String imagePath = product['imageUrl'];
                                    String imageUrl = (collectionName ==
                                            'makeup')
                                        ? _getSupabaseImageUrl(imagePath)
                                        : imagePath; // Use Supabase for makeup images

                                    if (collectionName == 'makeup') {
                                      return MakeupCard(
                                        imgPath: imageUrl,
                                        title: product['name'] ?? 'No name',
                                        price: product['price']?.toString() ??
                                            '0.0',
                                        onAddToCart: (cartItem) {
                                          // Handle cart addition
                                        },
                                      );
                                    } else if (collectionName == 'weaves') {
                                      Map<String, String> prices =
                                          Map<String, String>.from(
                                        product['prices']
                                            as Map<String, dynamic>,
                                      );
                                      return WeavesCard(
                                        imgPath: product['imageUrl'] ?? '',
                                        title: product['name'] ?? 'No name',
                                        prices: prices,
                                        onAddToCart: (cartItem) {
                                          // Handle cart addition
                                        },
                                      );
                                    } else {
                                      return ListTile(
                                        title:
                                            Text(product['name'] ?? 'No name'),
                                        subtitle: Text(product['description'] ??
                                            'No description'),
                                      );
                                    }
                                  }).toList(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                _scrollController.animateTo(
                                  _scrollController.offset + 200,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : (_searchController.text.isNotEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 50),
                              child: Text(
                                "No results found",
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ),
                          )
                        : const SizedBox()),

                const Center(
                  child: Text(
                    "Weaves",
                    style: TextStyle(fontSize: 23),
                  ),
                ),

                if (constraints.maxWidth >= 600.0)
                  ProductFrontalCards(
                    key: navbarKeys[1],
                    onAddToCart: (String) {},
                  )
                else
                  ProductFrontalCards2(
                    key: navbarKeys[1],
                    onAddToCart: (String) {},
                  ),

                const Center(
                  child: Text(
                    "MakeUp",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                if (constraints.maxWidth >= 600.0)
                  const ProductmakeupCard(
                      // onAddToCart: (String) {},
                      )
                else
                  const ProductmakeupCard2(),

                //AboutUs
                const Center(
                  child: Text(
                    "About Us",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                if (constraints.maxWidth >= 981.0)
                  Aboutus(key: navbarKeys[2])
                else
                  Aboutus2(key: navbarKeys[2]),

                //contact us
                Contactus(key: navbarKeys[3]),

                // footer
                const Footer(),
              ],
            ),
          ),
        );
      },
    );
  }

  void scrollToSection(int navIndex) {
    if (navIndex == 4) {
      //open login page
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
      return;
    }
    final key = navbarKeys[navIndex];
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget bookingcalender() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            "Installation Day: ${selectedDay.format(today)}",
          ),
        ),
        SizedBox(
          width: 300,
          child: TableCalendar(
            locale: 'en_US',
            rowHeight: 43,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            availableGestures: AvailableGestures.all,
            firstDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(day, today),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: today,
            onDaySelected: _onDayselected,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            onPressed: () {
              _showDialog();
            },
            child: const Text("Confirm"),
          ),
        ),
      ],
    );
  }
}

class MakeupCard extends StatefulWidget {
  final String imgPath;
  final String title;
  final String price;
  final Function(Map<String, String>) onAddToCart;

  const MakeupCard({
    required this.imgPath,
    required this.title,
    required this.price,
    required this.onAddToCart,
    super.key,
  });

  @override
  State<MakeupCard> createState() => _MakeupCardState();
}

class _MakeupCardState extends State<MakeupCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please log in to make a purchase."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
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
                  _addToCart(
                    context,
                    widget.title,
                    widget.imgPath,
                    widget.price,
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

  void _addToCart(
    BuildContext context,
    String productName,
    String imageUrl,
    String price,
    String name,
    DateTime date,
  ) {
    // Add to Firestore
    _firestore.collection('cart').add({
      'name': name,
      'installationDay': date.toIso8601String(),
      'productName': productName,
      'price': price,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify CartProvider
    widget.onAddToCart({
      'title': productName,
      'img': imageUrl,
      'price': price,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item added to cart successfully")),
    );
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
          ),
          const SizedBox(height: 5),
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${widget.price}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                _showLoginDialog(context);
              } else {
                _showUserDetailsDialog(context);
              }
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}

class WeavesCard extends StatefulWidget {
  final String imgPath;
  final String title;
  final Map<String, String> prices;
  final Function(Map<String, String>) onAddToCart;

  const WeavesCard({
    required this.imgPath,
    required this.title,
    required this.prices,
    required this.onAddToCart,
    super.key,
  });

  @override
  _WeavesCardState createState() => _WeavesCardState();
}

class _WeavesCardState extends State<WeavesCard> {
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
                print('Error: User not logged in.');
                _showLoginDialog(context);
                return;
              }

              if (_selectedInch == null) {
                print('Error: No size selected.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please select a size before adding to cart.'),
                  ),
                );
                return;
              }

              final cartItem = {
                'img': widget.imgPath,
                'title': widget.title,
                'price': _price,
              };
              print('Adding to cart: $cartItem');
              widget.onAddToCart(cartItem);
            },
            child: const Text("Add to Cart"),
          )
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
