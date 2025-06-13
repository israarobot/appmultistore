// import 'package:flutter/material.dart';

// class ProductsScreen extends StatefulWidget {
//   @override
//   _ProductsScreenState createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen> {
//   List<Map<String, dynamic>> products = [
//     {"id": "PROD001", "name": "Wireless Headphones", "sellers": [{"name": "David Brown", "price": 59.99}, {"name": "Emma Davis", "price": 62.50}], "buyers": 25, "category": "Electronics", "stock": 150, "rating": 4.5},
//     {"id": "PROD002", "name": "Smart Watch", "sellers": [{"name": "Frank Wilson", "price": 129.99}, {"name": "David Brown", "price": 135.00}], "buyers": 15, "category": "Wearables", "stock": 80, "rating": 4.7},
//     {"id": "PROD003", "name": "Laptop Stand", "sellers": [{"name": "Emma Davis", "price": 29.99}], "buyers": 40, "category": "Accessories", "stock": 200, "rating": 4.3},
//     {"id": "PROD004", "name": "Bluetooth Speaker", "sellers": [{"name": "David Brown", "price": 45.00}, {"name": "Sarah Lee", "price": 47.50}], "buyers": 30, "category": "Electronics", "stock": 120, "rating": 4.6},
//     {"id": "PROD005", "name": "Fitness Tracker", "sellers": [{"name": "Frank Wilson", "price": 79.99}], "buyers": 22, "category": "Wearables", "stock": 90, "rating": 4.4},
//     {"id": "PROD006", "name": "USB-C Hub", "sellers": [{"name": "Emma Davis", "price": 25.99}, {"name": "Mike Chen", "price": 27.00}], "buyers": 35, "category": "Accessories", "stock": 180, "rating": 4.5},
//     {"id": "PROD007", "name": "Gaming Mouse", "sellers": [{"name": "David Brown", "price": 39.99}], "buyers": 28, "category": "Gaming", "stock": 100, "rating": 4.8},
//     {"id": "PROD008", "name": "LED Desk Lamp", "sellers": [{"name": "Sarah Lee", "price": 34.50}, {"name": "Frank Wilson", "price": 36.00}], "buyers": 18, "category": "Home", "stock": 140, "rating": 4.2},
//     {"id": "PROD009", "name": "Portable Charger", "sellers": [{"name": "Mike Chen", "price": 19.99}], "buyers": 45, "category": "Electronics", "stock": 250, "rating": 4.7},
//     {"id": "PROD010", "name": "Wireless Keyboard", "sellers": [{"name": "David Brown", "price": 49.99}, {"name": "Emma Davis", "price": 52.00}], "buyers": 20, "category": "Accessories", "stock": 110, "rating": 4.6},
//     // Adding 40 more products
//     {"id": "PROD011", "name": "Noise-Cancelling Earbuds", "sellers": [{"name": "Sarah Lee", "price": 89.99}], "buyers": 32, "category": "Electronics", "stock": 95, "rating": 4.8},
//     {"id": "PROD012", "name": "Smart Thermostat", "sellers": [{"name": "Frank Wilson", "price": 149.99}, {"name": "Mike Chen", "price": 155.00}], "buyers": 12, "category": "Home", "stock": 60, "rating": 4.5},
//     {"id": "PROD013", "name": "Webcam", "sellers": [{"name": "David Brown", "price": 69.99}], "buyers": 25, "category": "Accessories", "stock": 130, "rating": 4.4},
//     {"id": "PROD014", "name": "Gaming Controller", "sellers": [{"name": "Emma Davis", "price": 59.99}, {"name": "Sarah Lee", "price": 62.00}], "buyers": 38, "category": "Gaming", "stock": 85, "rating": 4.7},
//     {"id": "PROD015", "name": "Smart Bulb", "sellers": [{"name": "Mike Chen", "price": 24.99}], "buyers": 50, "category": "Home", "stock": 200, "rating": 4.3},
//     {"id": "PROD016", "name": "External SSD", "sellers": [{"name": "David Brown", "price": 99.99}, {"name": "Frank Wilson", "price": 105.00}], "buyers": 15, "category": "Electronics", "stock": 70, "rating": 4.9},
//     {"id": "PROD017", "name": "Yoga Mat", "sellers": [{"name": "Emma Davis", "price": 29.99}], "buyers": 28, "category": "Fitness", "stock": 150, "rating": 4.6},
//     {"id": "PROD018", "name": "VR Headset", "sellers": [{"name": "Sarah Lee", "price": 299.99}, {"name": "Mike Chen", "price": 310.00}], "buyers": 8, "category": "Gaming", "stock": 40, "rating": 4.8},
//     {"id": "PROD019", "name": "Coffee Maker", "sellers": [{"name": "Frank Wilson", "price": 79.99}], "buyers": 35, "category": "Home", "stock": 90, "rating": 4.5},
//     {"id": "PROD020", "name": "Wireless Mouse", "sellers": [{"name": "David Brown", "price": 24.99}, {"name": "Emma Davis", "price": 26.50}], "buyers": 42, "category": "Accessories", "stock": 180, "rating": 4.4},
//     {"id": "PROD021", "name": "Action Camera", "sellers": [{"name": "Sarah Lee", "price": 199.99}], "buyers": 18, "category": "Electronics", "stock": 65, "rating": 4.7},
//     {"id": "PROD022", "name": "Smart Scale", "sellers": [{"name": "Mike Chen", "price": 49.99}, {"name": "Frank Wilson", "price": 52.00}], "buyers": 25, "category": "Fitness", "stock": 110, "rating": 4.6},
//     {"id": "PROD023", "name": "Monitor Arm", "sellers": [{"name": "David Brown", "price": 39.99}], "buyers": 30, "category": "Accessories", "stock": 140, "rating": 4.5},
//     {"id": "PROD024", "name": "Gaming Keyboard", "sellers": [{"name": "Emma Davis", "price": 89.99}, {"name": "Sarah Lee", "price": 92.00}], "buyers": 22, "category": "Gaming", "stock": 75, "rating": 4.8},
//     {"id": "PROD025", "name": "Air Purifier", "sellers": [{"name": "Frank Wilson", "price": 129.99}], "buyers": 15, "category": "Home", "stock": 85, "rating": 4.4},
//     {"id": "PROD026", "name": "Dash Cam", "sellers": [{"name": "Mike Chen", "price": 69.99}, {"name": "David Brown", "price": 72.50}], "buyers": 28, "category": "Electronics", "stock": 100, "rating": 4.6},
//     {"id": "PROD027", "name": "Resistance Bands", "sellers": [{"name": "Emma Davis", "price": 19.99}], "buyers": 35, "category": "Fitness", "stock": 200, "rating": 4.7},
//     {"id": "PROD028", "name": "Smart Doorbell", "sellers": [{"name": "Sarah Lee", "price": 149.99}, {"name": "Frank Wilson", "price": 155.00}], "buyers": 12, "category": "Home", "stock": 60, "rating": 4.5},
//     {"id": "PROD029", "name": "USB Microphone", "sellers": [{"name": "David Brown", "price": 59.99}], "buyers": 20, "category": "Accessories", "stock": 120, "rating": 4.8},
//     {"id": "PROD030", "name": "Gaming Headset", "sellers": [{"name": "Mike Chen", "price": 79.99}, {"name": "Emma Davis", "price": 82.00}], "buyers": 25, "category": "Gaming", "stock": 90, "rating": 4.7},
//     {"id": "PROD031", "name": "Electric Kettle", "sellers": [{"name": "Sarah Lee", "price": 39.99}], "buyers": 30, "category": "Home", "stock": 150, "rating": 4.6},
//     {"id": "PROD032", "name": "Smart Plug", "sellers": [{"name": "Frank Wilson", "price": 19.99}, {"name": "David Brown", "price": 21.50}], "buyers": 45, "category": "Home", "stock": 220, "rating": 4.4},
//     {"id": "PROD033", "name": "Phone Mount", "sellers": [{"name": "Emma Davis", "price": 14.99}], "buyers": 50, "category": "Accessories", "stock": 300, "rating": 4.5},
//     {"id": "PROD034", "name": "Drone", "sellers": [{"name": "Mike Chen", "price": 249.99}, {"name": "Sarah Lee", "price": 255.00}], "buyers": 10, "category": "Electronics", "stock": 40, "rating": 4.9},
//     {"id": "PROD035", "name": "Jump Rope", "sellers": [{"name": "Frank Wilson", "price": 12.99}], "buyers": 60, "category": "Fitness", "stock": 250, "rating": 4.3},
//     {"id": "PROD036", "name": "Smart Speaker", "sellers": [{"name": "David Brown", "price": 99.99}, {"name": "Emma Davis", "price": 105.00}], "buyers": 18, "category": "Electronics", "stock": 80, "rating": 4.7},
//     {"id": "PROD037", "name": "Laptop Sleeve", "sellers": [{"name": "Sarah Lee", "price": 19.99}], "buyers": 35, "category": "Accessories", "stock": 180, "rating": 4.6},
//     {"id": "PROD038", "name": "Smart Lock", "sellers": [{"name": "Mike Chen", "price": 179.99}, {"name": "Frank Wilson", "price": 185.00}], "buyers": 15, "category": "Home", "stock": 55, "rating": 4.5},
//     {"id": "PROD039", "name": "Gaming Chair", "sellers": [{"name": "David Brown", "price": 199.99}], "buyers": 12, "category": "Gaming", "stock": 45, "rating": 4.8},
//     {"id": "PROD040", "name": "Wireless Charger", "sellers": [{"name": "Emma Davis", "price": 29.99}, {"name": "Sarah Lee", "price": 32.00}], "buyers": 40, "category": "Electronics", "stock": 160, "rating": 4.4},
//     {"id": "PROD041", "name": "Dumbbell Set", "sellers": [{"name": "Frank Wilson", "price": 69.99}], "buyers": 20, "category": "Fitness", "stock": 100, "rating": 4.7},
//     {"id": "PROD042", "name": "Smart Mirror", "sellers": [{"name": "Mike Chen", "price": 299.99}, {"name": "David Brown", "price": 310.00}], "buyers": 8, "category": "Home", "stock": 30, "rating": 4.6},
//     {"id": "PROD043", "name": "HDMI Cable", "sellers": [{"name": "Emma Davis", "price": 9.99}], "buyers": 75, "category": "Accessories", "stock": 400, "rating": 4.5},
//     {"id": "PROD044", "name": "Smart Glasses", "sellers": [{"name": "Sarah Lee", "price": 249.99}, {"name": "Frank Wilson", "price": 260.00}], "buyers": 10, "category": "Wearables", "stock": 50, "rating": 4.8},
//     {"id": "PROD045", "name": "Mini Projector", "sellers": [{"name": "David Brown", "price": 149.99}], "buyers": 15, "category": "Electronics", "stock": 70, "rating": 4.7},
//     {"id": "PROD046", "name": "Travel Adapter", "sellers": [{"name": "Mike Chen", "price": 19.99}, {"name": "Emma Davis", "price": 21.50}], "buyers": 55, "category": "Accessories", "stock": 250, "rating": 4.6},
//     {"id": "PROD047", "name": "Kettlebell", "sellers": [{"name": "Sarah Lee", "price": 39.99}], "buyers": 25, "category": "Fitness", "stock": 120, "rating": 4.5},
//     {"id": "PROD048", "name": "Robot Vacuum", "sellers": [{"name": "Frank Wilson", "price": 199.99}, {"name": "David Brown", "price": 205.00}], "buyers": 18, "category": "Home", "stock": 60, "rating": 4.8},
//     {"id": "PROD049", "name": "Gaming Monitor", "sellers": [{"name": "Emma Davis", "price": 299.99}], "buyers": 12, "category": "Gaming", "stock": 40, "rating": 4.9},
//     {"id": "PROD050", "name": "Car Charger", "sellers": [{"name": "Mike Chen", "price": 14.99}, {"name": "Sarah Lee", "price": 16.50}], "buyers": 60, "category": "Accessories", "stock": 300, "rating": 4.4},
//   ];

//   void _showUpdateDialog(BuildContext context, Map<String, dynamic> product) {
//     final nameController = TextEditingController(text: product["name"]);
//     final categoryController = TextEditingController(text: product["category"]);
//     final stockController = TextEditingController(text: product["stock"].toString());

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Update Product', style: TextStyle(color: Colors.blue)),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: _inputDecoration('Product Name'),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: categoryController,
//                 decoration: _inputDecoration('Category'),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: stockController,
//                 keyboardType: TextInputType.number,
//                 decoration: _inputDecoration('Stock'),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             onPressed: () {
//               setState(() {
//                 final index = products.indexWhere((p) => p["id"] == product["id"]);
//                 products[index] = {
//                   ...products[index],
//                   "name": nameController.text,
//                   "category": categoryController.text,
//                   "stock": int.parse(stockController.text),
//                 };
//               });
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Product updated successfully")),
//               );
//             },
//             child: const Text('Update', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _deleteProduct(String id) {
//     setState(() {
//       products.removeWhere((product) => product["id"] == id);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Product deleted successfully")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text(
//           "Products Management",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//             shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF93441A), Colors.deepOrange],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: products.isEmpty
//           ? const Center(
//               child: Text(
//                 "No products found",
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(20),
//               itemCount: products.length,
//               itemBuilder: (context, index) => _buildProductCard(products[index], context),
//             ),
//     );
//   }

//   Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(Icons.inventory_2, color: Colors.blue, size: 35),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product["name"],
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Category: ${product["category"]}",
//                         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 16,
//               runSpacing: 8,
//               children: [
//                 _buildInfoChip("Buyers", "${product["buyers"]}", Colors.blue),
//                 _buildInfoChip("Stock", "${product["stock"]}", Color(0xFF93441A)),
//                 _buildInfoChip("Rating", "${product["rating"]}/5", Colors.yellow[800]!),
//                 ...product["sellers"].map((seller) => _buildInfoChip(
//                       seller["name"],
//                       "DT${seller["price"]}",
//                       Colors.green,
//                     )),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
//                   onPressed: () => _showUpdateDialog(context, product),
//                   tooltip: 'Edit Product',
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red, size: 28),
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text('Confirm Delete'),
//                         content: Text('Are you sure you want to delete ${product["name"]}?'),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('Cancel'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               _deleteProduct(product["id"]);
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                   tooltip: 'Delete Product',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoChip(String label, String value, Color color) {
//     return Chip(
//       avatar: CircleAvatar(
//         backgroundColor: color.withOpacity(0.1),
//         child: Text(
//           label[0],
//           style: TextStyle(color: color, fontSize: 12),
//         ),
//       ),
//       label: Text(
//         "$label: $value",
//         style: TextStyle(color: color, fontSize: 14),
//       ),
//       backgroundColor: color.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     );
//   }

//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Colors.blue, width: 2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       prefixIcon: Icon(
//         label == 'Product Name'
//             ? Icons.inventory
//             : label == 'Category'
//                 ? Icons.category
//                 : Icons.storage,
//         color: Colors.blue,
//       ),
//     );
//   }
// }