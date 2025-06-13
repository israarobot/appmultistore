import 'package:carthage_store/controllers/auth-controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  // Observable list to store cart items
  var cartItems = <Map<String, dynamic>>[].obs;

  // Observable to track loading state
  var isLoading = false.obs;

  // Observable to toggle checkout form
  var showCheckoutForm = false.obs;

  // Reference to the Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get AuthController instance
  final AuthController authController = Get.find<AuthController>();

  // Get current user ID from AuthController
  String? get _userId => authController.user?.uid;

  @override
  void onInit() {
    super.onInit();
    // Fetch cart items when controller is initialized
    fetchCartItems();
  }

  // Fetch cart items from Firestore for the current user
  Future<void> fetchCartItems() async {
    if (_userId == null) {
      Get.snackbar('Error', 'Please log in to view your cart',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      QuerySnapshot snapshot = await _firestore
          .collection('carts')
          .doc(_userId)
          .collection('items')
          .get();

      cartItems.clear();
      cartItems.addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['cartItemId'] = doc.id; // Store document ID for updates/deletes
        return data;
      }).toList());
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cart items: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Add product to cart
  Future<void> addToCart(Map<String, dynamic> product) async {
    if (_userId == null) {
      Get.snackbar('Error', 'Please log in to add items to cart',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Check if product is already in cart
      final existingItem = cartItems.firstWhereOrNull(
        (item) => item['productId'] == product['id'],
      );

      if (existingItem != null) {
        // Update quantity if product already exists
        await _firestore
            .collection('carts')
            .doc(_userId)
            .collection('items')
            .doc(existingItem['cartItemId'])
            .update({
          'quantity': (existingItem['quantity'] ?? 1) + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new product to cart
        final cartItem = {
          'productId': product['id'],
          'name': product['name'],
          'sale_price': product['sale_price'],
          'image_urls': product['image_urls'],
          'quantity': 1,
          'uid': _userId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('carts')
            .doc(_userId)
            .collection('items')
            .add(cartItem);
      }

      // Refresh cart items
      await fetchCartItems();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add to cart: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Update item quantity in cart
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (_userId == null) {
      Get.snackbar('Error', 'Please log in to update cart',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await _firestore
          .collection('carts')
          .doc(_userId)
          .collection('items')
          .doc(cartItemId)
          .update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh cart items
      await fetchCartItems();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update quantity: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    if (_userId == null) {
      Get.snackbar('Error', 'Please log in to remove items from cart',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await _firestore
          .collection('carts')
          .doc(_userId)
          .collection('items')
          .doc(cartItemId)
          .delete();

      // Refresh cart items
      await fetchCartItems();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove from cart: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate subtotal
  double calculateSubtotal() {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + ((item['sale_price'] ?? 0.0) * (item['quantity'] ?? 1)),
    );
  }

  // Submit checkout details to Firestore
  Future<void> submitCheckout({
    required String name,
    required String location,
    required String email,
    required String phone,
  }) async {
    if (_userId == null) {
      Get.snackbar('Error', 'Please log in to submit order',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final orderData = {
        'userId': _userId,
        'name': name,
        'location': location,
        'email': email,
        'phone': phone,
        'items': cartItems.toList(),
        'subtotal': calculateSubtotal(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      await _firestore.collection('orders').add(orderData);

      // Clear cart after successful order
      for (var item in cartItems) {
        await _firestore
            .collection('carts')
            .doc(_userId)
            .collection('items')
            .doc(item['cartItemId'])
            .delete();
      }

      cartItems.clear();
      showCheckoutForm.value = false;

      Get.snackbar('Success', 'Order placed successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}