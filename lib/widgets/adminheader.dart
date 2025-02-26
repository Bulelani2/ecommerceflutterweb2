import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/styles/style.dart';
import 'package:web_application/widgets/site_logo.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    required this.onNavMenuTap,
  });

  final Function() onNavMenuTap;

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
          Text(
            "Admin",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: CustomColor.textcolor,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton(
              onPressed: () {
                onNavMenuTap();
              },
              child: Text(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: CustomColor.textcolor,
                ),
                "Logout",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
