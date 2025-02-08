class Expense {
  int? id;
  int categoryId;
  double amount;
  DateTime date;

  Expense({this.id, required this.categoryId, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      categoryId: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}