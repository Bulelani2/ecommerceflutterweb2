import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Container(
      color: CustomColor.bgdark1,
      //margin: const EdgeInsets.only(bottom: 10),
      height: screenHeight / 1.6,
      constraints: const BoxConstraints(
        minHeight: 350,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/Logo/bulelani-logo.png",
            width: screenWidth / 3.5,
          ),
          Text(
            "Welcome to Bulelani, where beauty meets excellence!\n Our expert team specializes in selling and installing\n luxurious frontal weaves, ensuring you look and\n feel your absolute best.",
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: CustomColor.textcolor,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
