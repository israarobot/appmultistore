import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add product to favorites
  Future<bool> addToFavorites(Map<String, dynamic> product) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user signed in');
        return false;
      }

      final favoriteData = {
        'product_id': product['id'],
        'name': product['name'],
        'image_urls': product['image_urls'],
        'rating': product['rating'],
        'name_seller': product['name_seller'],
        'sale_price': product['sale_price'],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(product['id'].toString())
          .set(favoriteData);
      
      print('Added ${product['name']} to favorites');
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove product from favorites
  Future<bool> removeFromFavorites(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user signed in');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId)
          .delete();
      
      print('Removed product $productId from favorites');
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Check if product is in favorites
  Stream<bool> isFavorite(String productId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }
}