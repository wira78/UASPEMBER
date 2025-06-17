import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailPage({Key? key, required this.transactionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = TransactionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: FutureBuilder<Transaction?>(
        future: database.fetchTransactionById(transactionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          final transaction = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Judul:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(transaction.title),
                const SizedBox(height: 16),
                const Text(
                  'Kategori:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(transaction.category),
                const SizedBox(height: 16),
                const Text(
                  'Tanggal:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(transaction.date.toString()), 
                const SizedBox(height: 16),
                const Text(
                  'Jumlah:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Rp ${transaction.amount.toStringAsFixed(2)}'), 
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(transaction.description.isEmpty ? '-' : transaction.description),
                const SizedBox(height: 16),
                const Text(
                  'Sumber:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(transaction.source),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: const Text('Edit'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Transaksi'),
                            content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true) {
                          try {
                            await database.deleteTransaction(transactionId);
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menghapus: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}