import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carthage_store/controllers/auth-controller.dart';

class AdminAccountSettingsScreen extends StatefulWidget {
  @override
  _AdminAccountSettingsScreenState createState() => _AdminAccountSettingsScreenState();
}

class _AdminAccountSettingsScreenState extends State<AdminAccountSettingsScreen> {
  final AuthController _authController = Get.find<AuthController>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late bool _notificationsEnabled;
  late bool _twoFactorAuth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _authController.userData['fullName'] ?? "Admin User");
    _emailController = TextEditingController(text: _authController.user?.email ?? "admin@example.com");
    _passwordController = TextEditingController();
    _notificationsEnabled = _authController.userData['notificationsEnabled'] ?? true;
    _twoFactorAuth = _authController.userData['twoFactorAuth'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Account Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF93441A), Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView( // Removed Obx here
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Profile Information"),
            const SizedBox(height: 20),
            _buildProfileSection(),
            const SizedBox(height: 30),
            _buildHeader("Security Settings"),
            const SizedBox(height: 20),
            _buildSecuritySection(),
            const SizedBox(height: 30),
            _buildHeader("Preferences"),
            const SizedBox(height: 20),
            _buildPreferencesSection(),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.deepOrange,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF93441A)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email, color: Color(0xFF93441A)),
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text(
                "Change Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF93441A)),
              onTap: () {
                _showChangePasswordDialog();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text(
                "Two-Factor Authentication",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              value: _twoFactorAuth,
              activeColor: const Color(0xFF93441A),
              onChanged: (value) {
                setState(() {
                  _twoFactorAuth = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SwitchListTile(
          title: const Text(
            "Email Notifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          value: _notificationsEnabled,
          activeColor: const Color(0xFF93441A),
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF93441A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _authController.isLoading ? null : _saveChanges,
        child: _authController.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Save Changes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      )),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF93441A)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF93441A),
            ),
            onPressed: () async {
              await _changePassword();
              Navigator.pop(context);
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters.');
      return;
    }

    try {
      await _authController.user?.updatePassword(_passwordController.text.trim());
      Get.snackbar('Success', 'Password updated successfully');
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar('Error', 'Please re-authenticate to change your password.');
      } else {
        Get.snackbar('Error', e.message ?? 'Failed to update password.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    }
  }

  Future<void> _saveChanges() async {
    try {
      final user = _authController.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fullName': _nameController.text.trim(),
          'notificationsEnabled': _notificationsEnabled,
          'twoFactorAuth': _twoFactorAuth,
          'updatedAt': Timestamp.now(),
        });
        await _authController.fetchUserData();
        Get.snackbar('Success', 'Settings saved successfully');
      } else {
        Get.snackbar('Error', 'No user is currently signed in.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}