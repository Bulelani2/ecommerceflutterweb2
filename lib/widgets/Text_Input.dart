// import 'package:flutter/material.dart';
// import 'package:web_application/constants/colors.dart';

// class TextInput extends StatelessWidget {
//   final TextEditingController textEditingController;
//   final bool isPass;
//   final String hintText;
//   final IconData icon;
//   final String? Function(String?)? validator;

//   const TextInput({
//     super.key,
//     required this.textEditingController,
//     this.isPass = false,
//     required this.hintText,
//     required this.icon,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: SizedBox(
//         width: 400,
//         child: TextFormField(
//           style: TextStyle(
//             color: CustomColor.bgdark1,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//           obscureText: isPass,
//           controller: textEditingController,
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hintText,
//             hintStyle: TextStyle(
//               color: CustomColor.bgdark1,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//             prefixIcon: Icon(
//               icon,
//               color: CustomColor.bgdark2,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 15,
//               horizontal: 20,
//             ),
//             border: InputBorder.none,
//             filled: true,
//             fillColor: CustomColor.bglight,
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide.none,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 width: 2,
//                 color: CustomColor.bgdark2,
//               ),
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';

class TextInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;
  final Widget? suffixIcon; // Add suffixIcon parameter

  const TextInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.icon,
    this.validator,
    this.suffixIcon, // Initialize suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SizedBox(
        width: 400,
        child: TextFormField(
          style: TextStyle(
            color: CustomColor.bgdark1,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          obscureText: isPass,
          controller: textEditingController,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: CustomColor.bgdark1,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Icon(
              icon,
              color: CustomColor.bgdark2,
            ),
            suffixIcon: suffixIcon, // Set the suffixIcon here
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            border: InputBorder.none,
            filled: true,
            fillColor: CustomColor.bglight,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: CustomColor.bgdark2,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
