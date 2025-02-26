import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/products.dart';

class SecProducts extends StatelessWidget {
  const SecProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      padding: const EdgeInsets.all(30),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      children: [
        for (int i = 0; i < productsMakeUpItems.length; i++)
          Container(
            decoration: BoxDecoration(
              color: CustomColor.bglight,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 5),
                    color: Theme.of(context).primaryColor.withOpacity(.2),
                    spreadRadius: 2,
                    blurRadius: 5),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  productsMakeUpItems[i]["img"],
                  height: 100,
                  width: 100,
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    productsMakeUpItems[i]["title"],
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Buy Now"),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
