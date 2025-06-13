import 'package:carthage_store/controllers/auth-controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5E8DD),
              Color(0xFFF8F1EB),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 24,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF93441A),
                        Color(0xFFB56538),
                      ],
                    ),
                  ),
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            SliverToBoxAdapter(
              child: Obx(
                () => authController.isLoading
                    ? Container(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF93441A))),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: Color(0xFF93441A),
                                child: Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              authController.userData['fullName'] ?? 'User Name',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              authController.user?.email ?? 'Email not available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (authController.errorMessage.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    authController.errorMessage.value,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                              ),
                            SizedBox(height: 24),
                            _buildProfileOption(
                              Icons.edit,
                              "Edit Profile",
                              () {
                                Get.toNamed('/edit-profile');
                              },
                            ),
                            _buildProfileOption(
                              Icons.shopping_bag,
                              "My Orders",
                              () {
                                Get.toNamed('/orders');
                              },
                            ),
                            _buildProfileOption(
                              Icons.settings,
                              "Settings",
                              () {
                                Get.toNamed('/settings');
                              },
                            ),
                            _buildProfileOption(
                              Icons.logout,
                              "Logout",
                              () async {
                                await authController.logout();
                              },
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF93441A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF93441A),
                  size: 28,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      ),
    );
  }
}