import 'package:flutter/material.dart';
import 'package:web_application/styles/style.dart';
import 'package:web_application/widgets/site_logo.dart';

class SecHeader extends StatelessWidget {
  const SecHeader({super.key, this.onMenuTap});
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.maxFinite,
      margin: const EdgeInsets.fromLTRB(40, 5, 20, 5),
      decoration: decHeader,
      child: Row(
        children: [
          const SiteLogo(),
          const Spacer(),
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }
}
