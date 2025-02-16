class Expense {
  int? id;
  String note;
  int categoryId;
  double amount;
  DateTime date;

  Expense(
      {this.id,
      required this.categoryId,
      required this.note,
      required this.amount,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'category': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      note: map['note'],
      categoryId: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}
