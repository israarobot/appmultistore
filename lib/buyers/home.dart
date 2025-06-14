import 'package:carthage_store/controllers/add_product_controller.dart';
import 'package:carthage_store/controllers/favorite_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import './product_details_screen.dart';
import './product_card.dart';
import './cart_bottom_sheet.dart';
import './history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final AddProductController controller = Get.put(AddProductController());
  final FavoriteController favoriteController = Get.put(FavoriteController());
  var isLoading = false.obs;
  var allProducts = <Map<String, dynamic>>[].obs;

  // List of product categories with icons and colors
  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.all_inclusive, 'color': Colors.grey},
    {"name": "Electronics", "icon": Icons.tv, 'color': Colors.blue},
    {"name": "Clothing", "icon": Icons.checkroom, 'color': Colors.purple},
    {"name": "Parfum", "icon": Icons.spa, 'color': Colors.green},
    {"name": "Make-up", "icon": Icons.brush, 'color': const Color(0xFF93441A)},
    {"name": "skincare", 'icon': Icons.face_retouching_natural, 'color': Colors.orange},
    {"name": "Jewellery", "icon": Icons.diamond, 'color': Colors.pink},
  ];

  static const String fallbackImageUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for fade effect
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    fetchAllProducts();
    // Update search query on text change
    _searchController.addListener(() => _searchQuery.value = _searchController.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products from Firestore and validate media URLs
  Future<void> fetchAllProducts() async {
    isLoading.value = true;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      allProducts.clear();
      allProducts.addAll(await Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        // Validate image URLs
        data['image_urls'] = data['image_urls'] is List
            ? await Future.wait((data['image_urls'] as List).map((url) async => await isValidImageUrl(url) ? url : fallbackImageUrl))
            : [fallbackImageUrl];
        // Validate and convert video URL
        data['video_url'] = data['video_url']?.isNotEmpty == true && await isValidVideoUrl(data['video_url'])
            ? convertUrl(data['video_url'])
            : null;
        return data;
      })));
      Get.snackbar('Success', 'Products fetched successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Convert Google Drive URLs to direct media URLs
  String convertUrl(String? url) {
    if (url == null || url.trim().isEmpty) return fallbackImageUrl;
    final RegExp driveFileRegex = RegExp(r'https://drive.google.com/file/d/([a-zA-Z0-9_-]+)');
    final RegExp driveOpenRegex = RegExp(r'https://drive.google.com/open\?id=([a-zA-Z0-9_-]+)');
    final RegExp driveViewRegex = RegExp(r'https://drive.google.com/file/d/([a-zA-Z0-9_-]+)/view');
    
    final fileMatch = driveFileRegex.firstMatch(url);
    if (fileMatch != null) {
      return 'https://drive.google.com/uc?export=media&id=${fileMatch.group(1)}';
    }
    
    final openMatch = driveOpenRegex.firstMatch(url);
    if (openMatch != null) {
      return 'https://drive.google.com/uc?export=media&id=${openMatch.group(1)}';
    }
    
    final viewMatch = driveViewRegex.firstMatch(url);
    if (viewMatch != null) {
      return 'https://drive.google.com/uc?export=media&id=${viewMatch.group(1)}';
    }
    
    return url;
  }

  // Validate image URLs
  Future<bool> isValidImageUrl(String url) async {
    if (url.isEmpty || url == fallbackImageUrl) return true;
    try {
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 && ['image/png', 'image/jpeg', 'image/gif', 'image/bmp'].contains(response.headers['content-type']?.split(';')[0]);
    } catch (e) {
      return false;
    }
  }

  // Validate video URLs
  Future<bool> isValidVideoUrl(String url) async {
    if (url.isEmpty) return true;
    if (RegExp(r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/').hasMatch(url)) return true;
    try {
      final response = await http.head(Uri.parse(convertUrl(url))).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 && ['video/mp4', 'video/webm', 'video/ogg'].contains(response.headers['content-type']?.split(';')[0]);
    } catch (e) {
      return false;
    }
  }

  // Show cart bottom sheet
  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategoryList()),
            SliverToBoxAdapter(child: _buildPromoBanner()),
            SliverToBoxAdapter(child: _buildProductGrid()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // Build app bar with menu, title, and actions
  AppBar _buildAppBar() {
    return AppBar(
      leading: FadeInDown(child: _buildIconButton(Icons.menu, () {})),
      title: FadeInDown(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, color: Color(0xFF93441A)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Carthage Store',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      actions: [
        FadeInDown(child: _buildIconButton(Icons.shopping_cart, () => _showCartBottomSheet(context)), delay: const Duration(milliseconds: 200)),
        FadeInDown(child: _buildIconButton(Icons.history, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()))), delay: const Duration(milliseconds: 400)),
      ],
    );
  }

  // Build styled icon button
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.grey.shade100, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: IconButton(onPressed: onPressed, icon: Icon(icon, color: Colors.black87, size: 26)),
    );
  }

  // Build search bar with clear and filter options
  Widget _buildSearchBar() {
    return SlideInUp(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 16),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF93441A)),
                    suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, color: Color(0xFF93441A)), onPressed: () => _searchController.clear())
                        : const Icon(Icons.mic, color: Color(0xFF93441A))),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FadeInRight(child: _buildIconButton(Icons.filter_list, () {})),
          ],
        ),
      ),
    );
  }

  // Build horizontal category list
  Widget _buildCategoryList() {
    return SlideInUp(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            bool isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: FadeInRight(
                delay: Duration(milliseconds: 100 * index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [categories[index]["color"], categories[index]["color"].withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : LinearGradient(colors: [Colors.grey.shade100, Colors.white]),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Icon(categories[index]["icon"], size: 20, color: isSelected ? Colors.white : categories[index]["color"]),
                      const SizedBox(width: 8),
                      Text(categories[index]["name"], style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build promotional banner
  Widget _buildPromoBanner() {
    return ZoomIn(
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(image: AssetImage('assets/images/animation.jpg'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInLeft(child: Text("New Collection", style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))),
                  const SizedBox(height: 8),
                  FadeInLeft(child: Text("Discount 50% for the\nfirst transaction", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)), delay: const Duration(milliseconds: 200)),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      child: Text("Shop Now", style: GoogleFonts.poppins(color: const Color(0xFF93441A), fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build product grid with filtered products
  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInDown(child: Text("Top Selling", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),
              FadeInDown(child: TextButton(onPressed: fetchAllProducts, child: Text("View All", style: GoogleFonts.poppins(color: const Color(0xFF93441A), fontSize: 14)))),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (isLoading.value) return const Center(child: CircularProgressIndicator());
            final filteredProducts = _getFilteredProducts();
            if (filteredProducts.isEmpty) return Center(child: Text('No products found', style: GoogleFonts.poppins(fontSize: 16)));
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.6),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) => FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: filteredProducts[index]))),
                  child: ProductCard(product: filteredProducts[index], favoriteController: favoriteController),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Filter products by category and search query
  List<Map<String, dynamic>> _getFilteredProducts() {
    final query = _searchQuery.value.toLowerCase();
    var filteredProducts = List<Map<String, dynamic>>.from(allProducts.cast<Map<String, dynamic>>());
    if (_selectedCategoryIndex != 0) {
      filteredProducts = filteredProducts.where((product) => product['category']?.toString().toLowerCase() == categories[_selectedCategoryIndex]["name"].toLowerCase()).toList();
    }
    if (query.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) => product['name']?.toString().toLowerCase().contains(query) == true || product['category']?.toString().toLowerCase().contains(query) == true).toList();
    }
    return filteredProducts;
  }

  // Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 2))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              if (index == 1) Navigator.pushNamed(context, '/search');
              if (index == 2) Navigator.pushNamed(context, '/favorites');
              if (index == 3) Navigator.pushNamed(context, '/profile');
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF93441A),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  // Build floating action button for chat
  Widget _buildFloatingActionButton(BuildContext context) {
    return ZoomIn(
      child: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: const Color(0xFF93441A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}