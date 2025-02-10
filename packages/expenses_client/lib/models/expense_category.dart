class ExpenseCategory {
  int? id;
  String note;
  String categoryName;
  int categoryId;
  double amount;
  DateTime date;

  ExpenseCategory(
      {this.id,
      required this.categoryId,
      required this.categoryName,
      required this.note,
      required this.amount,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'category': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  static ExpenseCategory fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'],
      note: map['note'],
      categoryId: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryName: map['categoryName'],
    );
  }
}
