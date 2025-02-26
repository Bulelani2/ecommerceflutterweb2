import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/nav_items.dart';
import 'package:web_application/pages/Cart_page.dart';

class DrawerMobile2 extends StatelessWidget {
  const DrawerMobile2(
      {super.key, required this.onNavItemTap, required this.cartItemCount});
  final Function(int) onNavItemTap;
  final int cartItemCount; // New parameter to pass the cart item count
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CustomColor.bgdark1,
      child: ListView(
        children: [
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Padding(
          //     padding: const EdgeInsets.only(
          //       left: 20,
          //       top: 2,
          //       bottom: 20,
          //     ),
          //     child: IconButton(
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //         },
          //         icon: const Icon(Icons.close)),
          //   ),
          // ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close)),
              ),
              // Cart Icon
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                child: IconButton(
                  padding: const EdgeInsets.only(right: 20),
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        size: 30,
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text(
                              '$cartItemCount',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CartPage(), // Pass the cart items to CartPage
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          for (int i = 0; i < navIcons2.length; i++)
            ListTile(
              onTap: () {
                onNavItemTap(i);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 30),
              leading: Icon(navIcons[i]),
              titleTextStyle: TextStyle(
                color: CustomColor.textcolor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              title: Text(navTitles2[i]),
            ),
        ],
      ),
    );
  }
}
