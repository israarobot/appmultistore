import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, dynamic> _userData = <String, dynamic>{}.obs;

  User? get user => _auth.currentUser;
  bool get isLoading => _isLoading.value;
  RxString get errorMessage => _errorMessage;
  Map<String, dynamic> get userData => _userData.value;

  @override
  void onInit() {
    super.onInit();
    if (user != null) {
      fetchUserData();
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }

  Future<void> fetchUserData() async {
    try {
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          _userData.value = userDoc.data() as Map<String, dynamic>;
        } else {
          _errorMessage.value = "User data not found.";
        }
      }
    } catch (e) {
      _errorMessage.value = "Failed to fetch user data: $e";
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required bool agreeToTerms,
  }) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      _errorMessage.value = "Please fill in all fields.";
      return;
    }

    if (password.length < 6) {
      _errorMessage.value = "Password must be at least 6 characters.";
      return;
    }

    if (!agreeToTerms) {
      _errorMessage.value = "Please agree to the terms and conditions.";
      return;
    }

    _isLoading.value = true;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email.trim(),
          'fullName': fullName.trim(),
          'role': role,
          'createdAt': Timestamp.now(),
        });

        await fetchUserData();
        Get.offNamed('/login');
      } else {
        _errorMessage.value = "Failed to create user.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage.value = "The email is already in use.";
          break;
        case 'invalid-email':
          _errorMessage.value = "The email is invalid.";
          break;
        case 'weak-password':
          _errorMessage.value = "The password is too weak.";
          break;
        default:
          _errorMessage.value = e.message ?? "Registration failed.";
      }
    } catch (e) {
      _errorMessage.value = "An unexpected error occurred: $e";//connection
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage.value = "Please fill in both email and password fields.";
      return;
    }

    _isLoading.value = true;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _navigateBasedOnRole(userCredential.user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage.value = "No user found with this email.";// Aucun compte n’existe avec cet email.
          break;
        case 'wrong-password':
          _errorMessage.value = "Incorrect password.";
          break;
        case 'invalid-email':
          _errorMessage.value = "The email is invalid.";
          break;
        default:
          _errorMessage.value = e.message ?? "Login failed.";
      }
    } catch (e) {
      _errorMessage.value = "An unexpected error occurred: $e";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading.value = true;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? '',
            'fullName': user.displayName ?? 'Google User',
            'role': 'buyer',
            'createdAt': Timestamp.now(),
          }
          );
        }

        await _navigateBasedOnRole(user);
      } else {
        _errorMessage.value = "Google Sign-In failed.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          _errorMessage.value = "An account already exists with a different credential.";
          break;
        default:
          _errorMessage.value = e.message ?? "Google Sign-In failed.";
      }
    } catch (e) {
      _errorMessage.value = "An unexpected error occurred during Google Sign-In: $e";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _navigateBasedOnRole(User? user) async {
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        _errorMessage.value = "User data not found.";
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['role'] as String? ?? 'unknown';

      if (role == 'unknown') {
        await _auth.signOut();
        _errorMessage.value = "User role not defined.";
        return;
      }

      await fetchUserData();

      if (role == 'buyer') {
        Get.offNamed('/home');
      } else if (role == 'seller') {
        Get.offNamed('/dashboard-seller');
      } else if (role == 'admin') {
        Get.offNamed('/admin');
      } else {
        await _auth.signOut();
        _errorMessage.value = "You are not authorized to access.";
      }
    } else {
      _errorMessage.value = "Login failed.";
    }
  }

  Future<void> updateProfile({required String fullName, String? email}) async {
    if (fullName.isEmpty) {
      _errorMessage.value = "Full name cannot be empty.";
      return;
    }
    if (email != null && email.isEmpty) {
      _errorMessage.value = "Email cannot be empty.";
      return;
    }

    _isLoading.value = true;

    try {
      if (user != null) {
        Map<String, dynamic> updateData = {
          'fullName': fullName,
          'updatedAt': Timestamp.now(),
        };
        
        if (email != null && email != user!.email) {
          updateData['email'] = email;
          await user!.updateEmail(email);
        }

        await _firestore.collection('users').doc(user!.uid).update(updateData);
        await user!.updateDisplayName(fullName);

        await fetchUserData();

        Get.snackbar('Success', 'Profile updated successfully');
        Get.back();
      } else {
        _errorMessage.value = "No user is currently signed in.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage.value = "The email is already in use.";
          break;
        case 'invalid-email':
          _errorMessage.value = "The email is invalid.";
          break;
        case 'requires-recent-login':
          _errorMessage.value = "Please re-authenticate to update email.";
          break;
        default:
          _errorMessage.value = e.message ?? "Failed to update profile.";
      }
    } catch (e) {
      _errorMessage.value = "Failed to update profile: $e";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _googleSignIn.signOut();
      await _auth.signOut();
      _userData.clear();
      Get.offAllNamed('/login');
    } catch (e) {
      _errorMessage.value = "Failed to log out: $e";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _errorMessage.value = "Failed to fetch users: $e";
      return [];
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _isLoading.value = true;
      await _firestore.collection('users').doc(userId).delete();
      if (_auth.currentUser?.uid == userId) {
        await _googleSignIn.signOut();
        await _auth.currentUser?.delete();
        _userData.clear();
      }
      Get.snackbar('Success', 'User deleted');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _errorMessage.value = 'Please re-authenticate to delete this user.';
      } else {
        _errorMessage.value = 'Failed to delete user: ${e.message}';
      }
    } catch (e) {
      _errorMessage.value = 'Failed to delete user: $e';
    } finally {
      _isLoading.value = false;
    }
  }
}