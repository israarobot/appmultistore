import 'package:carthage_store/controllers/auth-controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SellersScreen extends StatefulWidget {
  const SellersScreen({super.key});

  @override
  _SellersScreenState createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Sellers Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF93441A), Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(
        () => authController.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF93441A)),
                ),
              )
            : authController.errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          authController.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            authController.clearError();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF93441A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: authController.getAllUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF93441A),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final sellers = snapshot.data
                          ?.where((user) => user['role'] == 'seller')
                          .toList();
                      if (sellers == null || sellers.isEmpty) {
                        return const Center(
                          child: Text(
                            "No sellers found",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: sellers.length,
                        itemBuilder: (context, index) =>
                            _buildSellerCard(sellers[index], context),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildSellerCard(Map<String, dynamic> seller, BuildContext context) {
    final createdAt = seller['createdAt'] != null
        ? DateFormat('yyyy-MM-dd')
            .format((seller['createdAt'] as Timestamp).toDate())
        : 'Unknown';
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.purple.shade100,
                  child: Text(
                    seller["fullName"]?[0] ?? 'S',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller["fullName"] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        seller["email"] ?? 'No Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip("Products", "${seller["products"] ?? 0}", Colors.purple),
                _buildInfoChip("Sales", "${seller["sales"] ?? 0}", Colors.blue),
                _buildInfoChip("Status", seller["role"] ?? 'seller', Colors.green),
                _buildInfoChip("Phone", seller["phone"] ?? 'Unknown', Colors.teal),
                _buildInfoChip("Joined", createdAt, const Color(0xFF93441A)),
                _buildInfoChip("Revenue", "DT${seller["totalRevenue"] ?? 0.0}", Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Store: ${seller["storeName"] ?? 'Unknown'}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                  onPressed: () => _showUpdateDialog(context, seller),
                  tooltip: 'Edit Seller',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete ${seller["fullName"]}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await authController.deleteUser(seller["id"]);
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Delete Seller',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Map<String, dynamic> seller) {
    final nameController = TextEditingController(text: seller["fullName"]);
    final emailController = TextEditingController(text: seller["email"]);
    final phoneController = TextEditingController(text: seller["phone"]);
    final storeNameController = TextEditingController(text: seller["storeName"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Seller', style: TextStyle(color: Colors.purple)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: _inputDecoration('Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: _inputDecoration('Phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storeNameController,
                decoration: _inputDecoration('Store Name'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await _firestore.collection('users').doc(seller["id"]).update({
                  'fullName': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'storeName': storeNameController.text.trim(),
                  'updatedAt': Timestamp.now(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Seller updated successfully")),
                );
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update seller: $e")),
                );
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Text(
          label[0],
          style: TextStyle(color: color, fontSize: 12),
        ),
      ),
      label: Text(
        "$label: $value",
        style: TextStyle(color: color, fontSize: 14),
      ),
      backgroundColor: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(
        label == 'Name'
            ? Icons.person
            : label == 'Email'
                ? Icons.email
                : label == 'Phone'
                    ? Icons.phone
                    : Icons.store,
        color: Colors.purple,
      ),
    );
  }
}