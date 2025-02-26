import 'package:firebase_auth/firebase_auth.dart' as user;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_application/Database/Cart_provider.dart';
import 'package:web_application/constants/keys.dart';
import 'package:web_application/firebase_options.dart';
import 'package:web_application/pages/admin/Admin.dart';
import 'package:web_application/pages/home_page.dart';
import 'package:web_application/pages/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  try {
    await Supabase.initialize(
      url: SupaBaseuri,
      anonKey: SupaBaseanonKey,
    );
  } catch (e) {
    print('Error applying Stripe settings: $e');
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isAdminLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdminLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool isAdminLoggedIn = snapshot.data ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Bulelani's Beauty Bliss",
          theme: ThemeData.dark(),
          home: isAdminLoggedIn
              ? const AdminPage()
              : StreamBuilder<user.User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);

                    if (userSnapshot.hasData && userSnapshot.data != null) {
                      // Set user ID in CartProvider when a user logs in
                      cartProvider.setUser(userSnapshot.data!);

                      return const UserPage(); // Regular user is logged in
                    } else {
                      // Clear user ID from CartProvider when no one is logged in
                      cartProvider.setUser(null);

                      return const HomePage(); // No one is logged in
                    }
                  },
                ),
        );
      },
    );
  }
}
