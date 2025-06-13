import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  String _selectedPaymentMethod = 'Credit Card';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment Successful!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentMethodSelector(),
              SizedBox(height: 20),
              _buildTextField(
                controller: _cardHolderController,
                label: "Cardholder Name",
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? "Please enter cardholder name" : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _cardNumberController,
                label: "Card Number",
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value!.isEmpty) return "Please enter card number";
                  if (value.length < 16) return "Card number must be 16 digits";
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _expiryDateController,
                      label: "Expiry Date (MM/YY)",
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                      validator: (value) {
                        if (value!.isEmpty) return "Please enter expiry date";
                        if (!RegExp(r"^(0[1-9]|1[0-2])\/\d{2}$").hasMatch(value)) {
                          return "Invalid format (MM/YY)";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _cvvController,
                      label: "CVV",
                      icon: Icons.lock,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      validator: (value) {
                        if (value!.isEmpty) return "Please enter CVV";
                        if (value.length < 3) return "CVV must be 3 digits";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              _buildOrderSummary(),
              SizedBox(height: 20),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethod,
      decoration: InputDecoration(
        labelText: "Payment Method",
        prefixIcon: Icon(Icons.payment, color: Color(0xFF93441A)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: ['Credit Card', 'PayPal', 'Cash on Delivery']
          .map((method) => DropdownMenuItem(value: method, child: Text(method)))
          .toList(),
      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF93441A)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: validator,
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
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
          Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: TextStyle(color: Colors.grey)),
              Text("DT200.00", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Shipping", style: TextStyle(color: Colors.grey)),
              Text("DT10.00", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("DT210.00", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF93441A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF93441A),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          "Pay Now",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}