import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> cart = [];
  String? userId;

  void setUser(User? user) {
    userId = user?.uid;
    if (userId != null) {
      _fetchCartFromFirestore();
    } else {
      clearCart();
    }
    notifyListeners();
  }

  Future<void> _fetchCartFromFirestore() async {
    if (userId == null) return;

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items');
      final snapshot = await cartRef.get();

      // print('Fetched ${snapshot.docs.length} items from Firestore.');

      cart = snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching cart from Firestore: $e');
    }
  }

  double getTotalPrice() {
    return cart.fold(0.0, (total, item) {
      return total +
          (double.tryParse(item['price']?.replaceAll('\$', '') ?? '0') ?? 0);
    });
  }

  Future<void> addToCart(
      Map<String, dynamic> item, BuildContext context) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to log in to add items to the cart.'),
        ),
      );
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items');
      final docRef = await cartRef.add(item);

      cart.add({
        ...item,
        'id': docRef.id,
      });
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added to cart successfully!'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error adding item to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart: $e'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> removeFromCart(int index) async {
    if (userId == null) return;

    try {
      final itemToRemove = cart[index];
      cart.removeAt(index);
      notifyListeners();

      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items');
      await cartRef.doc(itemToRemove['id']).delete();
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }
}
