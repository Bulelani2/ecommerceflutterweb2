import 'package:flutter/material.dart';

class SiteLogo extends StatelessWidget {
  const SiteLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Bulelani's Beauty Bliss",
      style: TextStyle(
        fontSize: 18,
        color: Color.fromARGB(255, 132, 211, 248),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
