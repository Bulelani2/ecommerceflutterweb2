import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:web_application/Database/Cart_provider.dart';
import 'package:web_application/pages/home_page.dart';
import 'package:web_application/widgets/contactus.dart';
import 'package:web_application/widgets/drawer2.dart';
import 'package:web_application/widgets/footer.dart';
import 'package:web_application/widgets/intro.dart';
import 'package:web_application/widgets/productmakeup.dart';
import 'package:web_application/widgets/productmakeup2.dart';
import 'package:web_application/widgets/productsfrontal.dart';
import 'package:web_application/widgets/productsfrontal2.dart';
import 'package:web_application/widgets/sec_header.dart';
import 'package:web_application/widgets/sec_intro.dart';
import '../constants/colors.dart';
import '../constants/keys.dart';
import '../widgets/header2.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Cart related
  List<String> cartItems = []; // List to track cart items
  List<QueryDocumentSnapshot> _searchResults = []; // Search results

  final List<GlobalKey> navbarKeys = List.generate(4, (index) => GlobalKey());
  DateTime today = DateTime.now();
  var selectedDay = DateFormat("E, dd-MM-yyyy");

  void _onDayselected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  void addToCart(Map<String, String> itemData) {
    // Add item to the CartProvider
    context
        .read<CartProvider>()
        .addToCart(itemData, context); // Pass context for Snackbar

    // Optionally update cartItems if needed
    setState(() {
      cartItems = List<String>.from(
          context.read<CartProvider>().cart.map((item) => item['title']!));
    });
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
              : DrawerMobile2(
                  cartItemCount: context.watch<CartProvider>().cart.length,
                  onNavItemTap: (int navIndex) {
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
                  Header2(
                    onNavMenuTap: (int navIndex) {
                      scrollToSection(navIndex);
                    },
                    cartItemCount: context
                        .watch<CartProvider>()
                        .cart
                        .length, // Pass cart count
                  )
                else
                  SecHeader(
                    onMenuTap: () {
                      scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),

                // Your content here
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
                                        onAddToCart: addToCart,
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
                                        onAddToCart: addToCart,
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

                if (constraints.maxWidth >= 830.0)
                  ProductFrontalCards(
                    key: navbarKeys[1],
                    onAddToCart: addToCart, // Pass addToCart callback
                  )
                else
                  ProductFrontalCards2(
                    key: navbarKeys[1], onAddToCart: addToCart,
                    // Pass addToCart callback
                  ),

                const Center(
                  child: Text(
                    "MakeUp",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                if (constraints.maxWidth >= 830.0)
                  const ProductmakeupCard()
                else
                  const ProductmakeupCard2(),

                // Booking section (e.g., calendar)
                const Center(
                  child: Text(
                    "Installation",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: bookingcalender(),
                ),

                // Contact us section
                Contactus(key: navbarKeys[2]),

                // Footer
                const Footer(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Scroll to specific section
  void scrollToSection(int navIndex) async {
    if (navIndex == 3) {
      // final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final auth = FirebaseAuth.instance;

      await auth.signOut();
      // await cartProvider.clearCart();
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Clear cart data
      cartProvider.clearCart();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      return;
    }
    final key = navbarKeys[navIndex];
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Booking calendar widget
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
            "Booked Day: ${selectedDay.format(today)}",
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

  // Dialog for confirmation
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

  // Upload booking data
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
                        builder: (context) => const UserPage(),
                      ),
                    );
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
                      ),
                    );
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
}
