import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/constants/nav_bar.dart';
import 'package:web_application/styles/style.dart';
import 'package:web_application/widgets/site_logo.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.onNavMenuTap});
  final Function(int) onNavMenuTap;
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
          for (int i = 0; i < navTitles.length; i++)
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
                  navTitles[i],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
