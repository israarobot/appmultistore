import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EarningsScreen extends StatelessWidget {
  // Mock total earnings
  final RxDouble totalEarnings = 1300.50.obs;

  // Mock monthly earnings data
  final RxList<MonthlyEarnings> monthlyEarnings = <MonthlyEarnings>[
    MonthlyEarnings(month: 'January', amount: 200.00),
    MonthlyEarnings(month: 'February', amount: 150.00),
    MonthlyEarnings(month: 'March', amount: 300.00),
    MonthlyEarnings(month: 'April', amount: 250.00),
    MonthlyEarnings(month: 'May', amount: 400.00),
  ].obs;

  // Mock recent transactions
  final RxList<Transaction> recentTransactions = <Transaction>[
    Transaction(orderId: 'ORD001', customerName: 'John Doe', amount: 200.00, date: '2025-05-01'),
    Transaction(orderId: 'ORD002', customerName: 'Jane Smith', amount: 150.00, date: '2025-05-03'),
    Transaction(orderId: 'ORD003', customerName: 'Alice Johnson', amount: 300.00, date: '2025-05-05'),
  ].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: (){
          Get.offNamed('/dashboard-seller');
          },
        ),
        title: Text(
          "Earnings",
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildTotalEarningsCard(),
          SizedBox(height: 20),
          _buildSectionTitle("Monthly Breakdown"),
          _buildMonthlyEarningsList(),
          SizedBox(height: 20),
          _buildSectionTitle("Recent Transactions"),
          _buildRecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Earnings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Obx(() => Text(
                  "DT${totalEarnings.value.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.green.shade600,
                  ),
                )),
            SizedBox(height: 8),
            Text(
              "As of May 07, 2025",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
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

  Widget _buildMonthlyEarningsList() {
    return Obx(() => Column(
          children: monthlyEarnings.map((earning) {
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Color(0xFF93441A),
                  size: 28,
                ),
                title: Text(
                  earning.month,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                trailing: Text(
                  "DT${earning.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildRecentTransactionsList() {
    return Obx(() => Column(
          children: recentTransactions.map((transaction) {
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  Icons.receipt,
                  color: Color(0xFF93441A),
                  size: 28,
                ),
                title: Text(
                  "Order #${transaction.orderId}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer: ${transaction.customerName}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      "Date: ${transaction.date}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  "DT${transaction.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}

// Data model for monthly earnings
class MonthlyEarnings {
  final String month;
  final double amount;

  MonthlyEarnings({required this.month, required this.amount});
}

// Data model for a transaction
class Transaction {
  final String orderId;
  final String customerName;
  final double amount;
  final String date;

  Transaction({
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.date,
  });
}