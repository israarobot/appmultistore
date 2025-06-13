import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carthage_store/controllers/add_product_controller.dart';
import 'checkout_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AddProductController _productController = Get.find<AddProductController>();
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch all products from the database when the screen initializes
    _fetchAllProducts();
    // Listen to search query changes
    _searchController.addListener(_filterProducts);
  }

  Future<void> _fetchAllProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all products without user_id filter
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      // Clear existing products in controller
      _productController.products.clear();

      // Process each document and validate URLs
      _productController.products.addAll(await Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        if (data['image_urls'] != null && data['image_urls'] is List) {
          List<String> validatedUrls = [];
          for (String url in data['image_urls']) {
            bool isValid = await _productController.isValidImageUrl(url);
            validatedUrls.add(isValid ? url : AddProductController.fallbackImageUrl);
          }
          data['image_urls'] = validatedUrls;
        } else {
          data['image_urls'] = [AddProductController.fallbackImageUrl];
        }
        if (data['video_url'] != null && data['video_url'].isNotEmpty) {
          bool isValid = await _productController.isValidVideoUrl(data['video_url']);
          if (!isValid) {
            data['video_url'] = null;
          } else {
            data['video_url'] = _productController.convertUrl(data['video_url']);
          }
        }
        print('Fetched product: ${data['name']}, Image URLs: ${data['image_urls']}, Video URL: ${data['video_url']}');
        return data;
      })));

      // Update filtered products
      setState(() {
        _filteredProducts = _productController.products;
      });

      Get.snackbar(
        'Success',
        'Products fetched successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error fetching products: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch products: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _productController.products
          .where((product) => product['name']?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return _filteredProducts.isEmpty
        ? Center(child: Text("No products found", style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ListTile(
                leading: Image.network(
                  product['image_urls']?.isNotEmpty ?? false
                      ? product['image_urls'][0]
                      : AddProductController.fallbackImageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.network(
                    AddProductController.fallbackImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  product['name'] ?? 'Unnamed Product',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "DT${product['sale_price']?.toStringAsFixed(2) ?? '0.00'} - Rating: N/A",
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart, color: Color(0xFF93441A)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}