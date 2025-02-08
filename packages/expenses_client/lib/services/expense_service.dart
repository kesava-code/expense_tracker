import 'package:expenses_client/data/expense_repository.dart';
import 'package:expenses_client/models/expense.dart';

class ExpenseService {
  final ExpenseRepository _expenseRepository;

  ExpenseService({ ExpenseRepository? expenseRepository})
      : _expenseRepository = expenseRepository ?? ExpenseRepository();

  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    double? minAmount,
    double? maxAmount,
    String? sortBy,
    String? sortOrder,
  }) async {
    return _expenseRepository.getExpenses(
      startDate: startDate,
      endDate: endDate,
      categoryIds: categoryIds,
      minAmount: minAmount,
      maxAmount: maxAmount,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }


  Future<Expense?> addExpense(Expense expense) async {
    final id = await _expenseRepository.addExpense(expense);
    if (id != null) {
      expense.id = id;
      return expense;
    }
    return null;
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseRepository.updateExpense(expense);
  }

  Future<void> deleteExpense(int id) async {
    await _expenseRepository.deleteExpense(id);
  }

  double calculateTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }
}