// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:web_application/constants/colors.dart';
// import 'package:web_application/pages/home_page.dart';
// import 'package:web_application/pages/user_page.dart';
// import 'package:web_application/widgets/Text_Input.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   // Function to validate email format
//   bool isValidEmail(String email) {
//     final emailRegex = RegExp(
//         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
//     return emailRegex.hasMatch(email);
//   }

//   // Login Function
//   Future<void> loginUser() async {
//     if (!isValidEmail(emailController.text.trim())) {
//       showErrorDialog("Invalid Email", "Please enter a valid email address.");
//       return;
//     }

//     if (passwordController.text.trim().length < 6) {
//       showErrorDialog(
//           "Weak Password", "Password must be at least 6 characters long.");
//       return;
//     }

//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const UserPage()),
//       );
//       // context.read<CartProvider>().fetchCartFromFirestore();
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = "An error occurred. Please try again.";
//       if (e.code == "user-not-found") {
//         errorMessage = "No user found with this email.";
//       } else if (e.code == "wrong-password") {
//         errorMessage = "Incorrect password.";
//       }
//       showErrorDialog("Login Failed", errorMessage);
//     }
//   }

//   // Register Function
//   Future<void> createUser() async {
//     if (!isValidEmail(emailController.text.trim())) {
//       showErrorDialog("Invalid Email", "Please enter a valid email address.");
//       return;
//     }

//     if (passwordController.text.trim().length < 6) {
//       showErrorDialog(
//           "Weak Password", "Password must be at least 6 characters long.");
//       return;
//     }

//     try {
//       // Check if email is already in use
//       QuerySnapshot userSnapshot = await FirebaseFirestore.instance
//           .collection("users")
//           .where("email", isEqualTo: emailController.text.trim())
//           .get();

//       if (userSnapshot.docs.isNotEmpty) {
//         showErrorDialog(
//             "Email In Use", "The email is already registered. Try logging in.");
//         return;
//       }

//       // Create new user in Firebase Authentication
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       // Save user to Firestore
//       await FirebaseFirestore.instance.collection("users").add(
//         {"email": emailController.text.trim()},
//       );

//       showSuccessDialog(
//           "Registration Successful", "Your account has been created.");
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = "An error occurred. Please try again.";
//       if (e.code == "email-already-in-use") {
//         errorMessage = "The email is already in use. Try logging in.";
//       }
//       showErrorDialog("Registration Failed", errorMessage);
//     }
//   }

//   // Error Dialog
//   void showErrorDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return CupertinoAlertDialog(
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 14, color: Colors.red),
//           ),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Success Dialog
//   void showSuccessDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return CupertinoAlertDialog(
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 14, color: Colors.green),
//           ),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final screenWidth = screenSize.width;
//     final screenHeight = screenSize.height;

//     return Scaffold(
//       body: Container(
//         color: CustomColor.bgdark1,
//         height: screenHeight / 1.6,
//         constraints: const BoxConstraints(minHeight: 800),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   padding: const EdgeInsets.only(right: 40, top: 40),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const HomePage()),
//                     );
//                   },
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//             Image.asset(
//               "assets/neles_logo.png",
//               width: screenWidth / 3.5,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//               child: TextInput(
//                 textEditingController: emailController,
//                 hintText: 'Email',
//                 icon: Icons.email_outlined,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: TextInput(
//                 textEditingController: passwordController,
//                 hintText: 'Password',
//                 icon: Icons.lock_clock_outlined,
//                 isPass: true,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: SizedBox(
//                 width: 200,
//                 child: TextButton(
//                   onPressed: () {},
//                   child: const Text("Forgot Password"),
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 75),
//                   child: SizedBox(
//                     width: 150,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         await loginUser();
//                       },
//                       child: const Text("Login"),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 150,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       await createUser();
//                     },
//                     child: const Text("Register"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_application/constants/colors.dart';
import 'package:web_application/pages/admin/Admin.dart';
import 'package:web_application/pages/home_page.dart';
import 'package:web_application/pages/user_page.dart';
import 'package:web_application/widgets/Text_Input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  // Function to validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  // Function to check admin credentials
  Future<bool> checkAdminCredentials(String email, String password) async {
    try {
      // Fetch admin credentials from Firestore
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc('admin')
          .get();

      if (adminDoc.exists) {
        String storedEmail = adminDoc['email'];
        String storedPassword = adminDoc['password'];

        // Compare provided credentials with the stored ones
        if (email == storedEmail && password == storedPassword) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking admin credentials: $e');
      return false;
    }
  }

  // Admin Login Function

  Future<void> loginAsAdmin() async {
    if (!isValidEmail(emailController.text.trim())) {
      showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (passwordController.text.trim().length < 6) {
      showErrorDialog(
          "Weak Password", "Password must be at least 6 characters long.");
      return;
    }

    // Check admin credentials
    bool isAdmin = await checkAdminCredentials(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (isAdmin) {
      // Save admin login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdminLoggedIn', true);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const AdminPage()), // Navigate to Admin Page
      );
      _clearFields();
    } else {
      showErrorDialog("Login Failed", "Invalid admin credentials.");
      _clearFields();
    }
  }

  // User Login Function
  Future<void> loginUser() async {
    if (!isValidEmail(emailController.text.trim())) {
      showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (passwordController.text.trim().length < 6) {
      showErrorDialog(
          "Weak Password", "Password must be at least 6 characters long.");
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserPage()),
      );
      _clearFields(); // Clear fields after successful login
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code;
      if (e.code == "user-not-found") {
        errorMessage = "No user found with this email.";
      } else if (e.code == "wrong-password") {
        errorMessage = "Incorrect password.";
      }
      showErrorDialog("Login Failed", errorMessage);
    }
  }

  // Register Function
  Future<void> createUser() async {
    if (!isValidEmail(emailController.text.trim())) {
      showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (passwordController.text.trim().length < 6) {
      showErrorDialog(
          "Weak Password", "Password must be at least 6 characters long.");
      return;
    }

    try {
      // Check if email is already in use
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: emailController.text.trim())
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        showErrorDialog(
            "Email In Use", "The email is already registered. Try logging in.");
        return;
      }

      // Create new user in Firebase Authentication
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save user to Firestore
      await FirebaseFirestore.instance.collection("users").add(
        {"email": emailController.text.trim()},
      );

      showSuccessDialog(
          "Registration Successful", "Your account has been created.");
      _clearFields(); // Clear fields after successful registration
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == "email-already-in-use") {
        errorMessage = "The email is already in use. Try logging in.";
      }
      showErrorDialog("Registration Failed", errorMessage);
    }
  }

  // Error Dialog
  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Success Dialog
  void showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Clear TextFields
  void _clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Container(
        color: CustomColor.bgdark1,
        height: screenHeight / 1.6,
        constraints: const BoxConstraints(minHeight: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: const EdgeInsets.only(right: 40, top: 40),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Image.asset(
              "assets/Logo/bulelani-logo.png",
              width: screenWidth / 3.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: TextInput(
                textEditingController: emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 20),
            TextInput(
              textEditingController: passwordController,
              hintText: 'Password',
              icon: Icons.lock_clock_outlined,
              isPass: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: 200,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password"),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 75),
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
                        await loginUser();
                      },
                      child: const Text("Login"),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      await createUser();
                    },
                    child: const Text("Register"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                width: 200,
                child: TextButton(
                  onPressed: () async {
                    await loginAsAdmin();
                  },
                  child: const Text("Login as Admin"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
