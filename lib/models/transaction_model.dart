class Transaction {
  String? id;
  String title;
  String category;
  String date;
  int amount;
  String description;
  String source;

  Transaction({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.description,
    required this.source,
  });

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      date: map['date'] ?? '',
      amount: map['amount'] ?? 0,
      description: map['description'] ?? '',
      source: map['source'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date,
      'amount': amount,
      'description': description,
      'source': source,
    };
  }
}