import 'package:carthage_store/controllers/auth-controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BuyersScreen extends StatefulWidget {
  const BuyersScreen({super.key});

  @override
  _BuyersScreenState createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Buyers Management",
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
                      final buyers = snapshot.data
                          ?.where((user) => user['role'] == 'buyer')
                          .toList();
                      if (buyers == null || buyers.isEmpty) {
                        return const Center(
                          child: Text(
                            "No buyers found",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: buyers.length,
                        itemBuilder: (context, index) =>
                            _buildBuyerCard(buyers[index], context),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildBuyerCard(Map<String, dynamic> buyer, BuildContext context) {
    final createdAt = buyer['createdAt'] != null
        ? DateFormat('yyyy-MM-dd')
            .format((buyer['createdAt'] as Timestamp).toDate())
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
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    buyer["fullName"]?[0] ?? 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyer["fullName"] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        buyer["email"] ?? 'No Email',
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
                _buildInfoChip("Purchases", "${buyer["purchases"] ?? 0}", Colors.blue),
                _buildInfoChip("Status", buyer["role"] ?? 'buyer', Colors.green),
                _buildInfoChip("Phone", buyer["phone"] ?? 'Unknown', Colors.purple),
                _buildInfoChip("Joined", createdAt, const Color(0xFF93441A)),
                _buildInfoChip("Spent", "DT${buyer["totalSpent"] ?? 0.0}", Colors.teal),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Address: ${buyer["address"] ?? 'Unknown'}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                  onPressed: () => _showUpdateDialog(context, buyer),
                  tooltip: 'Edit Buyer',
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
                            'Are you sure you want to delete ${buyer["fullName"]}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await authController.deleteUser(buyer["id"]);
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
                  tooltip: 'Delete Buyer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Map<String, dynamic> buyer) {
    final nameController = TextEditingController(text: buyer["fullName"]);
    final emailController = TextEditingController(text: buyer["email"]);
    final phoneController = TextEditingController(text: buyer["phone"]);
    final addressController = TextEditingController(text: buyer["address"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Buyer', style: TextStyle(color: Colors.green)),
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
                controller: addressController,
                decoration: _inputDecoration('Address'),
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
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await _firestore.collection('users').doc(buyer["id"]).update({
                  'fullName': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'address': addressController.text.trim(),
                  'updatedAt': Timestamp.now(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Buyer updated successfully")),
                );
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update buyer: $e")),
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
        borderSide: const BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(
        label == 'Name'
            ? Icons.person
            : label == 'Email'
                ? Icons.email
                : label == 'Phone'
                    ? Icons.phone
                    : Icons.location_on,
        color: Colors.green,
      ),
    );
  }
}