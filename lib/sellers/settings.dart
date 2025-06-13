import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carthage_store/controllers/auth-controller.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    // TextEditingController for the profile update form
    final TextEditingController fullNameController = TextEditingController(
      text: authController.userData['fullName'] ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Get.offNamed('/dashboard-seller');
          },
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF93441A), Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Obx(
        () => authController.isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildSectionTitle("Profile Information"),
                  _buildProfileInfo(
                    icon: Icons.person,
                    title: "Full Name",
                    value: authController.userData['fullName'] ?? 'Not set',
                  ),
                  _buildProfileInfo(
                    icon: Icons.email,
                    title: "Email",
                    value: authController.userData['email'] ?? 'Not set',
                  ),
                  _buildProfileInfo(
                    icon: Icons.store,
                    title: "Role",
                    value: authController.userData['role']?.toUpperCase() ?? 'Not set',
                  ),
                  _buildSectionTitle("Update Profile"),
                  _buildUpdateProfileForm(
                    fullNameController: fullNameController,
                    authController: authController,
                  ),
                  _buildSectionTitle("Preferences"),
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    title: "Notifications",
                    subtitle: "Enable or disable order notifications",
                    onTap: () {
                      Get.snackbar(
                        'Feature Coming Soon',
                        'Notification settings will be available in the next update.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Color(0xFF93441A),
                        colorText: Colors.white,
                        margin: EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: "Language",
                    subtitle: "Change app language",
                    onTap: () {
                      Get.snackbar(
                        'Feature Coming Soon',
                        'Language settings will be available in the next update.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Color(0xFF93441A),
                        colorText: Colors.white,
                        margin: EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                  ),
                  _buildSectionTitle("Support"),
                  _buildSettingsTile(
                    icon: Icons.help,
                    title: "Help & Support",
                    subtitle: "Get assistance with your account",
                    onTap: () {
                      Get.snackbar(
                        'Feature Coming Soon',
                        'Help & Support will be available in the next update.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Color(0xFF93441A),
                        colorText: Colors.white,
                        margin: EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.info,
                    title: "About",
                    subtitle: "App version and information",
                    onTap: () {
                      Get.snackbar(
                        'App Info',
                        'Seller Dashboard v1.0.0',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Color(0xFF93441A),
                        colorText: Colors.white,
                        margin: EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildLogoutButton(authController),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProfileInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: Color(0xFF93441A),
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateProfileForm({
    required TextEditingController fullNameController,
    required AuthController authController,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Full Name",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.person, color: Color(0xFF93441A)),
              ),
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            SizedBox(height: 16),
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF93441A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  minimumSize: Size(double.infinity, 48),
                ),
                onPressed: authController.isLoading
                    ? null
                    : () async {
                        await authController.updateProfile(
                          fullName: fullNameController.text.trim(),
                        );
                      },
                child: authController.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Update Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            Obx(
              () => authController.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        authController.errorMessage.value,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: Color(0xFF93441A),
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 14),
        elevation: 2,
      ),
      onPressed: () {
        Get.defaultDialog(
          title: "Logout",
          titleStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          middleText: "Are you sure you want to logout?",
          middleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey.shade600,
          ),
          textConfirm: "Yes",
          textCancel: "No",
          confirmTextColor: Colors.white,
          buttonColor: Colors.red.shade600,
          cancelTextColor: Colors.grey.shade600,
          onConfirm: () async {
            await authController.logout();
          },
       );
      },
      child: Text(
        "Logout",
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}