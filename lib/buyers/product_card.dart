import 'package:carthage_store/controllers/cart_controller.dart';
import 'package:carthage_store/controllers/favorite_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import './product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final FavoriteController favoriteController;
  final CartController cartController = Get.put(CartController());

  ProductCard({ // Removed 'const' from constructor
    Key? key,
    required this.product,
    required this.favoriteController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the first image URL from the image_urls array, or use a fallback
    final List<String> imageUrls = (product["image_urls"] as List<dynamic>?)?.cast<String>() ?? [];
    final String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : 'https://via.placeholder.com/150';

    print('Attempting to load image for product: ${product["name"]}, URL: $imageUrl');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Hero(
                    tag: product["name"] ?? product['id'] ?? 'product_${product.hashCode}',
                    child: Image.network(
                      imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image for ${product["name"]}: $error');
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Image unavailable',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: StreamBuilder<bool>(
                    stream: favoriteController.isFavorite(product['id'].toString()),
                    builder: (context, snapshot) {
                      bool isFavorite = snapshot.data ?? false;
                      return GestureDetector(
                        onTap: () async {
                          if (isFavorite) {
                            await favoriteController.removeFromFavorites(product['id'].toString());
                          } else {
                            await favoriteController.addToFavorites(product);
                          }
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"] ?? 'Unnamed Product',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFF93441A)),
                      const SizedBox(width: 2),
                      Text(
                        product["rating"]?.toString() ?? 'N/A',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product["name_seller"] ?? 'Unknown Seller',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "DT${product["sale_price"]?.toStringAsFixed(2) ?? '0.00'}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF93441A),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cartController.addToCart(product);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF93441A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}