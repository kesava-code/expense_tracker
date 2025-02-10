// Import DailyExpense
import 'package:categories_client/models/category.dart';
import 'package:categories_client/services/category_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:analytics/services/analytics_service.dart';
import 'package:expenses_client/expenses_client.dart';

import 'analytics_service_test.mocks.dart';

@GenerateMocks([ExpenseService, CategoryService])
void main() {
  late MockExpenseService mockExpenseService;
  late MockCategoryService mockCategoryService;
  late AnalyticsService analyticsService;

  setUp(() {
    mockExpenseService = MockExpenseService();
    mockCategoryService = MockCategoryService();
    analyticsService = AnalyticsService(
      expenseService: mockExpenseService,
      categoryService: mockCategoryService,
    );
  });

  group('AnalyticsService Tests', () {
    final testCategory1 = Category(id: 1, name: 'Food');
    final testCategory2 = Category(id: 2, name: 'Shopping');

    final testExpense1 = ExpenseCategory(
      categoryId: 1,
      categoryName: 'Food', // Add categoryName
      amount: 10.0,
      date: DateTime(2024, 1, 1),
      note: 'Test Note 1', // Add note
    );
    final testExpense2 = ExpenseCategory(
      categoryId: 2,
      categoryName: 'Shopping', // Add categoryName
      amount: 25.0,
      date: DateTime(2024, 1, 1),
      note: 'Test Note 2', // Add note
    );

    group('Daily Analytics', () {
      test('should return daily analytics', () async {
        final date = DateTime(2024, 1, 1);
        final expenses = [testExpense1, testExpense2];
        when(mockExpenseService.getExpenses(
          startDate: date,
          endDate: date.add(const Duration(days: 1)),
        )).thenAnswer((_) async => expenses);
        when(mockCategoryService.getCategories())
            .thenAnswer((_) async => [testCategory1, testCategory2]);

        final analytics = await analyticsService.getDailyAnalytics(date);

        expect(analytics['totalExpense'], 35.0);
        expect(analytics['highestExpense'], testExpense2);
        expect((analytics['categoryWiseExpense'] as Map).length, 2);
        expect(analytics['transactions'], expenses);
      });

      test('should return empty transactions list when no expenses', () async {
        final date = DateTime(2024, 1, 1);
        when(mockExpenseService.getExpenses(
          startDate: date,
          endDate: date.add(const Duration(days: 1)),
        )).thenAnswer((_) async => []); // No expenses
        when(mockCategoryService.getCategories())
            .thenAnswer((_) async => [testCategory1, testCategory2]);

        final analytics = await analyticsService.getDailyAnalytics(date);

        expect(analytics['transactions'], isEmpty); // Check for empty list
      });
    });

    // ... (Weekly and Monthly Analytics tests remain largely the same, but use ExpenseCategory)

    group('Helper Functions (Indirectly Tested)', () {
      // ... (Tests remain the same, just use ExpenseCategory)
    });

    group('getDailyExpensesForMonth', () {
      test('should return daily expenses for the month', () async {
        final date = DateTime(2024, 1, 15); // Example date in January
        final expenses = [
          ExpenseCategory(
            categoryId: 1,
            categoryName: 'Food',
            amount: 10.0,
            date: DateTime(2024, 1, 1),
            note: 'Note 1',
          ),
          ExpenseCategory(
            categoryId: 2,
            categoryName: 'Shopping',
            amount: 20.0,
            date: DateTime(2024, 1, 5),
            note: 'Note 2',
          ),
          // ... more expenses
        ];

        when(mockExpenseService.getExpenses(
                startDate: DateTime(2024, 1, 1),
                endDate: DateTime(2024, 1, 31).add(const Duration(days: 1))))
            .thenAnswer((_) async => expenses);

        final dailyExpenses = await analyticsService.getDailyExpensesForMonth(date);

        expect(dailyExpenses.length, DateTime(2024, 1, 31).day); // Check number of days
        expect(dailyExpenses[0].date, DateTime(2024, 1, 1)); // Check the first day
        expect(dailyExpenses[4].date, DateTime(2024, 1, 5)); // Check the 5th day
        expect(dailyExpenses[0].totalExpense, 10.0);
        expect(dailyExpenses[4].totalExpense, 20.0);
        // ... Check other days and total expenses
      });

      test('should return 0 expense if no expense in that day', () async {
        final date = DateTime(2024, 1, 15); // Example date in January
        final expenses = [
          ExpenseCategory(
            categoryId: 1,
            categoryName: 'Food',
            amount: 10.0,
            date: DateTime(2024, 1, 1),
            note: 'Note 1',
          ),
        ];

        when(mockExpenseService.getExpenses(
                startDate: DateTime(2024, 1, 1),
                endDate: DateTime(2024, 1, 31).add(const Duration(days: 1))))
            .thenAnswer((_) async => expenses);

        final dailyExpenses = await analyticsService.getDailyExpensesForMonth(date);

        expect(dailyExpenses[1].totalExpense, 0.0);
      });
    });

    group('getRecentExpenses', () {
      test('should return recent expenses from repository', () async {
        final expenses = [testExpense1, testExpense2];
        when(mockExpenseService.getExpenses(
                limit: 10, sortBy: 'date', sortOrder: 'DESC'))
            .thenAnswer((_) async => expenses);

        final result = await analyticsService.getRecentExpenses(10);

        expect(result, expenses);
        verify(mockExpenseService.getExpenses(
                limit: 10, sortBy: 'date', sortOrder: 'DESC'))
            .called(1);
      });

      test('should handle repository exceptions', () async {
        when(mockExpenseService.getExpenses(
                limit: 10, sortBy: 'date', sortOrder: 'DESC'))
            .thenThrow(Exception('Failed to get recent expenses'));

        expect(() async => await analyticsService.getRecentExpenses(10),
            throwsA(isA<Exception>()));
        verify(mockExpenseService.getExpenses(
                limit: 10, sortBy: 'date', sortOrder: 'DESC'))
            .called(1);
      });
    });
  });
}
