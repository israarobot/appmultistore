import 'package:carthage_store/controllers/add_product_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddProductController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
          onPressed: () => Get.offNamed('/dashboard-seller'),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF93441A), Color(0xFF6A1B9A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        centerTitle: true,
      ),
      body: Obx(
        () => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        'Product Name*',
                        controller.nameController,
                        validator: controller.validateRequired,
                      ),
                      _buildDropdown(
                        'Product Category*',
                        controller.categories,
                        controller.selectedCategory,
                        (value) => controller.selectedCategory.value = value,
                        validator: controller.validateRequired,
                      ),
                      _buildTextField('Brand', controller.brandController),
                      _buildTextField(
                        'Product Code*',
                        controller.codeController,
                        validator: controller.validateRequired,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Stock*',
                              controller.stockController,
                              keyboardType: TextInputType.number,
                              validator: controller.validateNumber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              'Unit*',
                              controller.units,
                              controller.selectedUnit,
                              (value) => controller.selectedUnit.value = value,
                              validator: controller.validateRequired,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Sale Price*',
                              controller.salePriceController,
                              keyboardType: TextInputType.number,
                              validator: controller.validateNumber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Discount*',
                              controller.discountController,
                              keyboardType: TextInputType.number,
                              validator: controller.validateNumber,
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        'Description*',
                        controller.descriptionController,
                        maxLines: 4,
                        validator: controller.validateRequired,
                      ),
                      // Multiple Image URLs
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Image URLs*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      Obx(
                        () => Column(
                          children: [
                            for (
                              int i = 0;
                              i < controller.imageUrlControllers.length;
                              i++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        'Image URL ${i + 1}*',
                                        controller.imageUrlControllers[i],
                                        validator:
                                            controller.validateRequiredUrl,
                                      ),
                                    ),
                                    if (controller.imageUrlControllers.length >
                                        1)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                        onPressed:
                                            () => controller
                                                .removeImageUrlField(i),
                                      ),
                                  ],
                                ),
                              ),
                            TextButton.icon(
                              onPressed: controller.addImageUrlField,
                              icon: const Icon(
                                Icons.add_circle,
                                color: Color(0xFF93441A),
                                size: 24,
                              ),
                              label: Text(
                                'Add Another Image URL',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: const Color(0xFF93441A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Video URL
                      _buildTextField(
                        'Video URL',
                        controller.videoUrlController,
                        validator: controller.validateOptionalUrl,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF93441A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child:
                              controller.isLoading.value
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Save & Publish',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF93441A),
                    strokeWidth: 3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: const Color(0xFF93441A),
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF93441A), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Rxn<String> selected,
    Function(String?) onChanged, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selected.value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: const Color(0xFF93441A),
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF93441A), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                .toList(),
        onChanged:
            Get.find<AddProductController>().isLoading.value ? null : onChanged,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color(0xFF2D2D2D),
        ),
      ),
    );
  }
}
