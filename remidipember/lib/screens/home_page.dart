import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart'; // Changed from database_service.dart
import '../widgets/transaction_card.dart';
import 'add_transaction_page.dart';
import 'transaction_detail_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionService = TransactionService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hitung Saldo'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTransactionPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card (Note: You'll need to implement getCurrentBalance in TransactionService)
          FutureBuilder<int>(
            future: _calculateBalance(transactionService), // Custom method
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Rp. ${snapshot.data?.toString() ?? '0'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Transactions List
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: transactionService.fetchTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No transactions yet'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Force refresh by recalling fetchTransactions
                    await transactionService.fetchTransactions();
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final transaction = snapshot.data![index];
                      return TransactionCard(
                        transaction: transaction,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailPage(
                              transactionId: transaction.id!,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate balance
  Future<int> _calculateBalance(TransactionService service) async {
    final transactions = await service.fetchTransactions();
    int balance = 0;
    for (var transaction in transactions) {
      // Assuming positive amounts are income and negative are expenses
      balance += transaction.amount;
    }
    return balance;
  }
}