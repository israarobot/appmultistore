import 'package:carthage_store/controllers/auth-controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController fullNameController = TextEditingController(
      text: authController.userData['fullName'] ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: authController.userData['email'] ?? '',
    );

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
              expandedHeight: 150,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Edit Profile",
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
                        height: MediaQuery.of(context).size.height - 150,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF93441A))),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Update Your Profile",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 24),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextField(
                                  controller: fullNameController,
                                  decoration: InputDecoration(
                                    labelText: "Full Name",
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.grey[600]),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF93441A),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(color: Colors.grey[600]),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFF93441A),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                  keyboardType: TextInputType.emailAddress,
                                ),
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
                            ElevatedButton(
                              onPressed: () async {
                                await authController.updateProfile(
                                  fullName: fullNameController.text.trim(),
                                  email: emailController.text.trim(),
                                );
                              },
                              child: Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF93441A),
                                minimumSize: Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: Colors.black.withOpacity(0.2),
                              ),
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
}