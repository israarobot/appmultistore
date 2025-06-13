import 'package:carthage_store/controllers/favorite_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteController _favoriteController = FavoriteController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(child: Text("Please sign in to view favorites", style: TextStyle(color: Colors.grey))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No favorites yet", style: TextStyle(color: Colors.grey)));
          }

          final favorites = snapshot.data!.docs;

          return Padding(
            padding: EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index].data() as Map<String, dynamic>;
                return _buildFavoriteCard(product, favorites[index].id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> product, String productId) {
    return Container(
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  product["image_urls"] is List ? product["image_urls"][0] : product["image_urls"],
                  height: 100, // Reduced height from 140 to 100
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100, // Match the reduced height
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: StreamBuilder<bool>(
                  stream: _favoriteController.isFavorite(productId),
                  builder: (context, snapshot) {
                    bool isFavorite = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () async {
                        if (isFavorite) {
                          await _favoriteController.removeFromFavorites(productId);
                        } else {
                          await _favoriteController.addToFavorites({
                            'id': productId,
                            'name': product['name'],
                            'image_urls': product['image_urls'],
                            'rating': product['rating'],
                            'name_seller': product['name_seller'],
                            'sale_price': product['sale_price'],
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.favorite,
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
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"] ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Color(0xFF93441A)),
                    SizedBox(width: 4),
                    Text(
                      product["rating"]?.toString() ?? '0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "DT${product["sale_price"]}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF93441A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}