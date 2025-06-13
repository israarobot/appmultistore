import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carthage_store/controllers/add_product_controller.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late AddProductController controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _categoryScrollController = ScrollController();

  // Category data for UI display (icons and colors)
  final Map<String, Map<String, dynamic>> categoryData = {
    'Electronics': {'icon': Icons.electrical_services, 'color': Colors.blue},
    'Clothing': {'icon': Icons.checkroom, 'color': Colors.purple},
    'Parfum': {'icon': Icons.water_drop, 'color': Colors.green},
    'Make-up': {'icon': Icons.brush, 'color': const Color(0xFF93441A)},
    'skincare': {'icon': Icons.face_retouching_natural, 'color': Colors.orange},
    'Jewellery': {'icon': Icons.diamond, 'color': Colors.pink},
  };

  @override
  void initState() {
    super.initState();
    // Initialize controller
    Get.put(AddProductController(), tag: 'AddProductController');
    controller = Get.find<AddProductController>(tag: 'AddProductController');
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    // Fetch all products and ensure UI updates
    controller.getAllProducts().then((_) {
      print('Products fetched: ${controller.products.length}');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.getAllProducts().then((_) {
                print('Refreshed products: ${controller.products.length}');
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        print('Rebuilding UI with isLoading: ${controller.isLoading.value}, products: ${controller.products.length}');
        return controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await controller.getAllProducts();
                  print('Refresh completed, products: ${controller.products.length}');
                },
                child: Column(
                  children: [
                    // Horizontal Category List
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListView(
                        controller: _categoryScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          // "All" category chip
                          _buildCategoryChip('All', null),
                          ...controller.categories.map((category) => _buildCategoryChip(
                                category,
                                categoryData[category]?['color'] ?? Colors.black,
                              )),
                        ],
                      ),
                    ),
                    // Product Grid
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildProductGrid(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildCategoryChip(String category, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Obx(() => FilterChip(
            label: Text(
              category,
              style: TextStyle(
                color: controller.selectedCategory.value == category ||
                        (category == 'All' && controller.selectedCategory.value == null)
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: controller.selectedCategory.value == category ||
                (category == 'All' && controller.selectedCategory.value == null),
            selectedColor: color?.withOpacity(0.8) ?? Colors.grey,
            backgroundColor: color?.withOpacity(0.1) ?? Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: color?.withOpacity(0.3) ?? Colors.grey),
            ),
            onSelected: (isSelected) {
              controller.selectedCategory.value = (isSelected && category != 'All') ? category : null;
              print('Selected category: ${controller.selectedCategory.value ?? 'All'}');
            },
          )),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    // Filter products based on selected category
    final filteredProducts = controller.selectedCategory.value == null
        ? controller.products.toList()
        : controller.products.where((product) => product['category'] == controller.selectedCategory.value).toList();

    print('Filtered products count: ${filteredProducts.length}');

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No products found'),
            SizedBox(height: 8),
            Text('Try refreshing or adding new products'),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final imageUrl = (product['image_urls'] is List && product['image_urls'].isNotEmpty)
            ? product['image_urls'].first
            : AddProductController.fallbackImageUrl;

        print('Rendering product: ${product['name']}, Image URL: $imageUrl');

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) {
                      print('Image load error for URL $url: $error');
                      return Image.network(
                        AddProductController.fallbackImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
              ),
              // Product Details
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DT${product['sale_price']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text('Are you sure you want to delete ${product['name']}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await controller.deleteProduct(product['id']);
                            print('Deleted product: ${product['name']}');
                          }
                        },
                        child: const Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final String category;

  const ProductListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final AddProductController controller = Get.find<AddProductController>(tag: 'AddProductController');

    // Ensure products are fetched
    controller.getAllProducts().then((_) {
      print('Products fetched for category $category: ${controller.products.length}');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Products'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.getAllProducts().then((_) {
                print('Refreshed products for category $category: ${controller.products.length}');
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        print('Rebuilding ProductListScreen with isLoading: ${controller.isLoading.value}, products: ${controller.products.length}');
        return controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await controller.getAllProducts();
                  print('Refresh completed for category $category, products: ${controller.products.length}');
                },
                child: _buildProductGrid(context, controller),
              );
      }),
    );
  }

  Widget _buildProductGrid(BuildContext context, AddProductController controller) {
    // Filter products based on category
    final filteredProducts = controller.products.where((product) => product['category'] == category).toList();

    print('Filtered products for category $category: ${filteredProducts.length}');

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No products found'),
            SizedBox(height: 8),
            Text('Try refreshing or adding new products'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final imageUrl = (product['image_urls'] is List && product['image_urls'].isNotEmpty)
            ? product['image_urls'].first
            : AddProductController.fallbackImageUrl;

        print('Rendering product in $category: ${product['name']}, Image URL: $imageUrl');

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) {
                      print('Image load error for URL $url: $error');
                      return Image.network(
                        AddProductController.fallbackImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
              ),
              // Product Details
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DT${product['sale_price']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text('Are you sure you want to delete ${product['name']}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await controller.deleteProduct(product['id']);
                            print('Deleted product: ${product['name']}');
                          }
                        },
                        child: const Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}