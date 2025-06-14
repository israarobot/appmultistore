import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

// CartBottomSheet is a StatefulWidget for a draggable cart UI
class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({super.key});

  @override
  _CartBottomSheetState createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  // Form key and text controllers for checkout form
  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  // Focus nodes for form fields to handle scrolling
  final _nameFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize CartController as a singleton
    Get.put(CartController(), permanent: true);
    // Add listeners to scroll to focused field
    [_nameFocusNode, _locationFocusNode, _emailFocusNode, _phoneFocusNode].forEach((node) {
      node.addListener(() {
        if (node.hasFocus) {
          Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    [_nameController, _locationController, _emailController, _phoneController].forEach((controller) => controller.dispose());
    [_nameFocusNode, _locationFocusNode, _emailFocusNode, _phoneFocusNode].forEach((node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    // Draggable sheet with dynamic content based on checkout form state
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFECEFF1)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Obx(() => cartController.showCheckoutForm.value
              ? _buildCheckoutForm(context, cartController, scrollController)
              : _buildCartView(context, cartController, scrollController)),
        ),
      ),
    );
  }

  // Builds the cart view with items and total
  Widget _buildCartView(BuildContext context, CartController cartController, ScrollController scrollController) {
    return Column(
      children: [
        // Header with title and close button
        _buildHeader(context, 'Your Shopping Cart', onClose: () => Navigator.pop(context)),
        // Cart items list or loading/empty state
        Expanded(
          child: Obx(() => cartController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : cartController.cartItems.isEmpty
                  ? _buildEmptyCart()
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: cartController.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartController.cartItems[index];
                        return _buildCartItem(cartController, cartItem, index);
                      },
                    )),
        ),
        // Footer with subtotal and checkout button
        _buildFooter(cartController),
      ],
    );
  }

  // Builds the header with title and action button
  Widget _buildHeader(BuildContext context, String title, {VoidCallback? onClose, VoidCallback? onBack}) {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
            ZoomIn(
              duration: const Duration(milliseconds: 400),
              child: IconButton(
                icon: Icon(onBack != null ? Icons.arrow_back : Icons.close_rounded, color: const Color(0xFF2D2D2D), size: 28),
                onPressed: onBack ?? onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds an empty cart message
  Widget _buildEmptyCart() {
    return Center(
      child: Text(
        'Your cart is empty',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  // Builds a single cart item
  Widget _buildCartItem(CartController cartController, Map cartItem, int index) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Product image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
                image: DecorationImage(
                  image: NetworkImage(cartItem['image_urls']?.isNotEmpty ?? false ? cartItem['image_urls'][0] : 'https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem['name'] ?? 'Unknown Product', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF2D2D2D))),
                  const SizedBox(height: 6),
                  Text('DT${(cartItem['sale_price'] ?? 0.0).toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFFE67E22))),
                ],
              ),
            ),
            // Quantity controls
            _buildQuantityControls(cartController, cartItem),
            // Remove button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
              onPressed: () => cartController.removeFromCart(cartItem['cartItemId']),
            ),
          ],
        ),
      ),
    );
  }

  // Builds quantity controls for a cart item
  Widget _buildQuantityControls(CartController cartController, Map cartItem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => cartItem['quantity'] > 1
                ? cartController.updateQuantity(cartItem['cartItemId'], cartItem['quantity'] - 1)
                : cartController.removeFromCart(cartItem['cartItemId']),
            child: const Icon(Icons.remove, size: 20, color: Color(0xFFE67E22)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(cartItem['quantity'].toString(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D2D2D))),
          ),
          GestureDetector(
            onTap: () => cartController.updateQuantity(cartItem['cartItemId'], (cartItem['quantity'] ?? 1) + 1),
            child: const Icon(Icons.add, size: 20, color: Color(0xFFE67E22)),
          ),
        ],
      ),
    );
  }

  // Builds the footer with subtotal and checkout button
  Widget _buildFooter(CartController cartController) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: Column(
          children: [
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF2D2D2D))),
                    Text('DT${cartController.calculateSubtotal().toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFFE67E22))),
                  ],
                )),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: cartController.cartItems.isEmpty ? null : () => cartController.showCheckoutForm.value = true,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 56),
                    shadowColor: const Color(0xFFE67E22).withOpacity(0.3),
                  ),
                  child: Text('Proceed to Checkout', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                )),
          ],
        ),
      ),
    );
  }

  // Builds the checkout form
  Widget _buildCheckoutForm(BuildContext context, CartController cartController, ScrollController scrollController) {
    // Define form fields with explicit types
    final List<Map<String, dynamic>> formFields = [
      {
        'controller': _nameController,
        'focusNode': _nameFocusNode,
        'label': 'Full Name',
        'validator': (String? value) => value!.isEmpty ? 'Please enter your name' : null,
      },
      {
        'controller': _locationController,
        'focusNode': _locationFocusNode,
        'label': 'Location/Address',
        'validator': (String? value) => value!.isEmpty ? 'Please enter your location' : null,
      },
      {
        'controller': _emailController,
        'focusNode': _emailFocusNode,
        'label': 'Email',
        'keyboardType': TextInputType.emailAddress,
        'validator': (String? value) => value!.isEmpty
            ? 'Please enter your email'
            : !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)
                ? 'Please enter a valid email'
                : null,
      },
      {
        'controller': _phoneController,
        'focusNode': _phoneFocusNode,
        'label': 'Phone Number',
        'keyboardType': TextInputType.phone,
        'validator': (String? value) => value!.isEmpty ? 'Please enter your phone number' : null,
      },
    ];

    return FocusScope(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                _buildHeader(context, 'Checkout Details', onBack: () => cartController.showCheckoutForm.value = false),
                const SizedBox(height: 20),
                // Form fields for user details
                ...formFields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final field = entry.value;
                  return FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 100 * index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: field['controller'] as TextEditingController,
                        focusNode: field['focusNode'] as FocusNode,
                        decoration: InputDecoration(
                          labelText: field['label'] as String,
                          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: field['keyboardType'] as TextInputType?,
                        validator: field['validator'] as String? Function(String?)?,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Submit button
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          await cartController.submitCheckout(
                            name: _nameController.text,
                            location: _locationController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          Get.snackbar('Error', 'Something went wrong: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 2,
                      minimumSize: const Size(double.infinity, 56),
                      shadowColor: const Color(0xFFE67E22).withOpacity(0.3),
                    ),
                    child: Text('Submit Order', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}