import 'package:carthage_store/controllers/auth-controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added this import
import 'package:flutter/material.dart';
import 'package:carthage_store/controllers/checkout_controller.dart';
import 'package:get/get.dart';

class OrdersScreen extends StatelessWidget {
  final CheckoutController checkoutController = Get.put(CheckoutController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Get.offNamed('/dashboard-seller');
          },
        ),
        title: const Text(
          "Orders",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF93441A), Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: checkoutController.fetchAllOrders(sellerId: authController.user?.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No orders available.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final orders = snapshot.data!.map((data) => Order.fromMap(data)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Order #${order.id}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Customer: ${order.customerName}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Item: ${order.item}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Price: DT${order.price.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(order, index),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Color(0xFF93441A);
        label = 'Pending';
        break;
      case 'in progress':
        color = Colors.blue.shade100;
        label = 'In Progress';
        break;
      case 'done':
        color = Colors.green.shade100;
        label = 'Done';
        break;
      case 'rejected':
        color = Colors.red.shade100;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey.shade100;
        label = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Poppins',
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Order order, int index) {
    if (order.status == 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton(
            label: 'Accept',
            icon: Icons.check,
            color: Colors.green.shade600,
            onPressed: () async {
              try {
                await checkoutController.updateOrderStatus(order.id, 'in progress');
                Get.snackbar(
                  'Order Accepted',
                  'Order #${order.id} is now in progress.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
                Get.forceAppUpdate();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to accept order: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            label: 'Reject',
            icon: Icons.close,
            color: Colors.red.shade600,
            onPressed: () async {
              try {
                await checkoutController.updateOrderStatus(order.id, 'rejected');
                Get.snackbar(
                  'Order Rejected',
                  'Order #${order.id} has been rejected.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
                Get.forceAppUpdate();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to reject order: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
          ),
        ],
      );
    } else if (order.status == 'in progress') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton(
            label: 'Mark as Done',
            icon: Icons.done_all,
            color: Colors.green.shade600,
            onPressed: () async {
              try {
                await checkoutController.updateOrderStatus(order.id, 'done');
                Get.snackbar(
                  'Order Completed',
                  'Order #${order.id} is now done.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
                Get.forceAppUpdate();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to complete order: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 2,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class Order {
  final String id;
  final String customerName;
  final String item;
  final String status;
  final String phoneNumber;
  final String email;
  final String deliveryAddress;
  final String paymentMethod;
  final double price;
  final String productId;
  final String sellerId;
  final Timestamp? createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.item,
    required this.status,
    required this.phoneNumber,
    required this.email,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.price,
    required this.productId,
    required this.sellerId,
    this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      id: data['id'] ?? '',
      customerName: data['customer_name'] ?? '',
      item: data['product_name'] ?? 'Unnamed Product',
      status: data['order_status'] ?? 'pending',
      phoneNumber: data['phone_number'] ?? '',
      email: data['email'] ?? '',
      deliveryAddress: data['delivery_address'] ?? '',
      paymentMethod: data['payment_method'] ?? 'Cash on Delivery',
      price: (data['price'] ?? 0.0).toDouble(),
      productId: data['product_id'] ?? '',
      sellerId: data['id_seller'] ?? '',
      createdAt: data['created_at'] as Timestamp?,
    );
  }
}