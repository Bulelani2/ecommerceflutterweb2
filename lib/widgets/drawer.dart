import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/nav_items.dart';

class DrawerMobile extends StatelessWidget {
  const DrawerMobile({super.key, required this.onNavItemTap});
  final Function(int) onNavItemTap;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CustomColor.bgdark1,
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 2,
                bottom: 20,
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
            ),
          ),
          for (int i = 0; i < navIcons.length; i++)
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
              title: Text(navTitles[i]),
            ),
        ],
      ),
    );
  }
}
