import 'package:carthage_store/admin/all_products.dart';
import 'package:carthage_store/admin/all_users.dart';
import 'package:carthage_store/buyers/Chat.dart';
import 'package:carthage_store/buyers/edit_profile_screen.dart';
import 'package:carthage_store/signup/signup_seller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carthage_store/admin/admin-settings.dart';
import 'package:carthage_store/admin/all_products.dart';
import 'package:carthage_store/admin/bayers.dart';
// import 'package:carthage_store/admin/products.dart';
import 'package:carthage_store/admin/profil.dart';
import 'package:carthage_store/admin/admin.dart';
import 'package:carthage_store/admin/sellers.dart';
import 'package:carthage_store/buyers/favorites_screen.dart';
import 'package:carthage_store/buyers/home.dart';
import 'package:carthage_store/login/login.dart';
import 'package:carthage_store/onboarding/onboarding_Screen.dart';
import 'package:carthage_store/buyers/payement/payment.dart';
import 'package:carthage_store/buyers/payement/payment_screen.dart';
import 'package:carthage_store/buyers/profile_screen.dart';
import 'package:carthage_store/buyers/search_screen.dart';
import 'package:carthage_store/sellers/dashboard_seller.dart';
import 'package:carthage_store/sellers/earning.dart';
import 'package:carthage_store/sellers/form.dart';
import 'package:carthage_store/sellers/orders.dart';
import 'package:carthage_store/sellers/settings.dart';
import 'package:carthage_store/signup/signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carthage Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => OnboardScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/signup_seller': (context) => SignupSellerScreen(),
        '/profile': (context) => ProfileScreen(),
        '/home': (context) => HomeScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/search': (context) => SearchScreen(),
        '/payement': (context) => PaymentScreen(),
        '/payement-sucess': (context) => PaymentSuccessScreen(),
        '/adminsettings': (context) => AdminAccountSettingsScreen(),
        '/admin': (context) => AdminDashboardScreen(),
        '/admin_products': (context) => CategoryScreen(),
        '/edit-profile': (context) => EditProfileScreen(),
        '/bayers': (context) => BuyersScreen(),
        '/chat': (context) => ChatScreen(),
        // '/products': (context) => ProductsScreen(),
        '/sellers': (context) => SellersScreen(),
        '/form_sellers': (context) => AddProductScreen(),
        '/dashboard-seller': (context) => SellerDashboard(),
        '/order-seller': (context) => OrdersScreen(),
        '/setting-seller': (context) => SettingsScreen(),
        '/earning-seller': (context) => EarningsScreen(),
        '/all_users': (context) => UsersScreen(),
      },
    );
  }
}