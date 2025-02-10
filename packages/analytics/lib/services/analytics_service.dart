import 'package:analytics/models/daily_expense.dart';
import 'package:categories_client/models/category.dart';
import 'package:categories_client/services/category_service.dart';
import 'package:expenses_client/expenses_client.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  final ExpenseService _expenseService;
  final CategoryService _categoryService;

  AnalyticsService({
    ExpenseService? expenseService,
    CategoryService? categoryService,
  })  : _expenseService = expenseService ?? ExpenseService(),
        _categoryService = categoryService ?? CategoryService();

  // --- Helper Functions ---

  Map<Category, List<ExpenseCategory>> _groupExpensesByCategory(
      List<ExpenseCategory> expenses, List<Category> categories) {
    return groupBy<ExpenseCategory, Category>(expenses, (expense) {
      return categories
          .firstWhere((category) => category.name == expense.categoryName);
    });
  }

  double _calculateTotalExpense(List<ExpenseCategory> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double _calculateAverageExpense(List<ExpenseCategory> expenses) {
    if (expenses.isEmpty) return 0;
    return _calculateTotalExpense(expenses) / expenses.length;
  }

  ExpenseCategory? _findHighestExpense(List<ExpenseCategory> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  // --- Analytics Methods ---

  Future<Map<String, dynamic>> getDailyAnalytics(DateTime date) async {
    final expenses = await _expenseService.getExpenses(
      startDate: date,
      endDate: date.add(const Duration(days: 1)), // End of the day
    );

    final categories = await _categoryService.getCategories();
    final categoryWiseExpenses = _groupExpensesByCategory(expenses, categories);

    return {
      'totalExpense': _calculateTotalExpense(expenses),
      'highestExpense': _findHighestExpense(expenses),
      'categoryWiseExpense': categoryWiseExpenses,
      'transactions': expenses, // Include transactions for the day
    };
  }

  Future<Map<String, dynamic>> getWeeklyAnalytics(DateTime startDate) async {
    final endDate = startDate.add(const Duration(days: 7));
    return _getRangeAnalytics(startDate, endDate);
  }

  Future<Map<String, dynamic>> getMonthlyAnalytics(DateTime monthStart) async {
    final endDate = DateTime(
        monthStart.year, monthStart.month + 1, 1); // Start of next month
    return _getRangeAnalytics(monthStart, endDate);
  }

  Future<Map<String, dynamic>> _getRangeAnalytics(
      DateTime startDate, DateTime endDate) async {
    final expenses = await _expenseService.getExpenses(
      startDate: startDate,
      endDate: endDate,
    );
    final categories = await _categoryService.getCategories();
    final categoryWiseExpenses = _groupExpensesByCategory(expenses, categories);

    return {
      'totalExpense': _calculateTotalExpense(expenses),
      'highestExpense': _findHighestExpense(expenses),
      'averageExpense': _calculateAverageExpense(expenses),
      'categoryWiseExpense': categoryWiseExpenses,
    };
  }

  Future<List<DailyExpense>> getDailyExpensesForMonth(DateTime date) async {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    final expenses = await _expenseService.getExpenses(
      startDate: firstDayOfMonth,
      endDate: lastDayOfMonth.add(const Duration(days: 1)),
    );

    final numberOfDays = lastDayOfMonth.day; // Number of days in the month

    // Create a map to hold daily expenses, initialized with 0 for all days
    final dailyExpensesMap = {
      for (int i = 1; i <= numberOfDays; i++)
        DateFormat('yyyy-MM-dd').format(DateTime(date.year, date.month, i)):
            0.0,
    };

    // Group expenses by day and add to the map
    for (final expense in expenses) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(expense.date);
      dailyExpensesMap[formattedDate] =
          (dailyExpensesMap[formattedDate] ?? 0.0) + expense.amount;
    }

    // Convert to List<DailyExpense>
    final dailyExpenses = dailyExpensesMap.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final totalExpense = entry.value;
      return DailyExpense(date: date, totalExpense: totalExpense);
    }).toList();

    // Sort by date to ensure correct order (important for the chart)
    dailyExpenses.sort((a, b) => a.date.compareTo(b.date));

    return dailyExpenses;
  }

  Future<List<ExpenseCategory>> getRecentExpenses(int limit) async {
    try {
      final expenses = await _expenseService.getExpenses(
          limit: limit, sortBy: 'date', sortOrder: 'DESC');
      return expenses;
    } catch (e) {
      rethrow; // Re-throw the error
    }
  }
}
