import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class TransactionService {
  final String baseUrl = 'https://remed-6f1a0-default-rtdb.firebaseio.com/';

  Future<List<Transaction>> fetchTransactions() async {
    final url = Uri.parse('$baseUrl/transactions.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data == null) return [];
      
      return data.entries.map((e) {
        return Transaction.fromMap(
          Map<String, dynamic>.from(e.value),
          e.key,
        );
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    } else {
      throw Exception('Failed to fetch transactions: ${response.statusCode}');
    }
  }

  Future<Transaction?> fetchTransactionById(String id) async {
    final url = Uri.parse('$baseUrl/transactions/$id.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      if (data == null) return null;
      
      return Transaction.fromMap(
        Map<String, dynamic>.from(data),
        id,
      );
    } else {
      throw Exception('Failed to fetch transaction: ${response.statusCode}');
    }
  }

  Future<String> addTransaction(Transaction transaction) async {
    final url = Uri.parse('$baseUrl/transactions.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toMap()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['name']; // Returns the generated ID
    } else {
      throw Exception('Failed to add transaction: ${response.statusCode}');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final url = Uri.parse('$baseUrl/transactions/${transaction.id}.json');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction: ${response.statusCode}');
    }
  }

  Future<void> deleteTransaction(String id) async {
    final url = Uri.parse('$baseUrl/transactions/$id.json');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction: ${response.statusCode}');
    }
  }

  Future<List<Transaction>> fetchTransactionsByCategory(String category) async {
    final url = Uri.parse('$baseUrl/transactions.json?orderBy="category"&equalTo="$category"');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data == null) return [];
      
      return data.entries.map((e) {
        return Transaction.fromMap(
          Map<String, dynamic>.from(e.value),
          e.key,
        );
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    } else {
      throw Exception('Failed to fetch transactions by category: ${response.statusCode}');
    }
  }

  // Additional method to fetch transactions by date range
  Future<List<Transaction>> fetchTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    // Firebase doesn't directly support date range queries, so we'll filter locally
    final allTransactions = await fetchTransactions();
    return allTransactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction.date);
      return transactionDate.isAfter(startDate) && transactionDate.isBefore(endDate);
    }).toList();
  }
}