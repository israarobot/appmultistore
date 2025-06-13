import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'auth-controller.dart';

class CheckoutController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>(); // Access AuthController

  Future<void> submitOrder({
    required Map<String, dynamic> product,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      // Get the current user's email from AuthController
      final String? userEmail = _authController.user?.email;
      if (userEmail == null) {
        throw Exception('No user is logged in.');
      }

      // Create order data
      final orderData = {
        'product_id': product['id'] ?? '',
        'product_name': product['name'] ?? 'Unnamed Product',
        'price': product['sale_price']?.toDouble() ?? 0.0,
        'id_seller': product['user_id'] ?? '',
        'customer_name': name,
        'phone_number': phone,
        'email': userEmail, // Use email from AuthController
        'delivery_address': address,
        'payment_method': 'Cash on Delivery',
        'order_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      };

      // Save order to Firestore
      await _firestore.collection('orders').add(orderData);
    } catch (e) {
      throw Exception('Failed to submit order: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders({String? sellerId, String? email}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('orders');
      if (sellerId != null) {
        query = query.where('id_seller', isEqualTo: sellerId);
      }
      if (email != null) {
        query = query.where('email', isEqualTo: email);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'order_status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}