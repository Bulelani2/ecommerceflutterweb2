// import 'package:flutter/material.dart';
// import 'package:web_application/constants/colors.dart';
// import 'package:web_application/constants/nav_items.dart';
// import 'package:web_application/styles/style.dart';
// import 'package:web_application/widgets/site_logo.dart';

// class Header2 extends StatelessWidget {
//   const Header2({super.key, required this.onNavMenuTap});
//   final Function(int) onNavMenuTap;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 70,
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//       width: double.maxFinite,
//       decoration: decHeader,
//       child: Row(
//         children: [
//           const SiteLogo(),
//           const Spacer(),
//           for (int i = 0; i < navTitles2.length; i++)
//             Padding(
//               padding: const EdgeInsets.only(right: 20),
//               child: TextButton(
//                 onPressed: () {
//                   onNavMenuTap(i);
//                 },
//                 child: Text(
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: CustomColor.textcolor,
//                   ),
//                   navTitles2[i],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/nav_items.dart';
import 'package:web_application/pages/Cart_page.dart';
import 'package:web_application/styles/style.dart';
import 'package:web_application/widgets/site_logo.dart';

class Header2 extends StatelessWidget {
  const Header2(
      {super.key, required this.onNavMenuTap, required this.cartItemCount});

  final Function(int) onNavMenuTap;
  final int cartItemCount; // New parameter to pass the cart item count

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: double.maxFinite,
      decoration: decHeader,
      child: Row(
        children: [
          const SiteLogo(),
          const Spacer(),
          for (int i = 0; i < navTitles2.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TextButton(
                onPressed: () {
                  onNavMenuTap(i);
                },
                child: Text(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CustomColor.textcolor,
                  ),
                  navTitles2[i],
                ),
              ),
            ),
          // Cart Icon
          IconButton(
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
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
        ],
      ),
    );
  }
}
