import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:expenses_client/data/expense_repository.dart';
import 'package:expenses_client/models/expense.dart';
import 'package:expenses_client/models/expense_category.dart';
import 'package:expenses_client/services/expense_service.dart';

import 'expenses_client_test.mocks.dart';

@GenerateMocks([ExpenseRepository])
void main() {
  late MockExpenseRepository mockExpenseRepository;
  late ExpenseService expenseService;

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    expenseService = ExpenseService(expenseRepository: mockExpenseRepository);
  });

  group('ExpenseService Tests', () {
    final testExpense = Expense(
      categoryId: 1,
      amount: 10.0,
      date: DateTime(2024, 1, 1),
      note: 'Test Note',
    );

    final testExpenseCategory = ExpenseCategory(
      categoryId: 1,
      categoryName: 'Category 1', // You'll likely need to mock the category name too
      amount: 10.0,
      date: DateTime(2024, 1, 1),
      note: 'Test Note',
    );

    group('getExpenses', () {
      test('should return expenses from repository', () async {
        final expenses = [testExpenseCategory]; // Use ExpenseCategory
        when(mockExpenseRepository.getExpenses()).thenAnswer((_) async => expenses);

        final result = await expenseService.getExpenses();

        expect(result, expenses);
        verify(mockExpenseRepository.getExpenses()).called(1);
      });

      test('should handle repository exceptions', () async {
        when(mockExpenseRepository.getExpenses()).thenThrow(Exception('Failed to get expenses'));

        expect(() async => await expenseService.getExpenses(), throwsA(isA<Exception>()));
        verify(mockExpenseRepository.getExpenses()).called(1);
      });

      test('should call repository with correct filter parameters', () async {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final categoryIds = [1, 2];
        final minAmount = 5.0;
        final maxAmount = 100.0;
        final sortBy = 'date';
        final sortOrder = 'DESC';
        final limit = 10;
        final offset = 5;

        when(mockExpenseRepository.getExpenses(
          startDate: startDate,
          endDate: endDate,
          categoryIds: categoryIds,
          minAmount: minAmount,
          maxAmount: maxAmount,
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
          offset: offset,
        )).thenAnswer((_) async => []);

        await expenseService.getExpenses(
          startDate: startDate,
          endDate: endDate,
          categoryIds: categoryIds,
          minAmount: minAmount,
          maxAmount: maxAmount,
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
          offset: offset,
        );

        verify(mockExpenseRepository.getExpenses(
          startDate: startDate,
          endDate: endDate,
          categoryIds: categoryIds,
          minAmount: minAmount,
          maxAmount: maxAmount,
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
          offset: offset,
        )).called(1);
      });
    });

    group('addExpense', () {
      test('should add expense and return expense with id', () async {
        when(mockExpenseRepository.addExpense(testExpense)).thenAnswer((_) async => 1);

        final result = await expenseService.addExpense(testExpense);

        expect(result?.id, 1);
        verify(mockExpenseRepository.addExpense(testExpense)).called(1);
      });

      test('should return null if expense not added', () async {
        when(mockExpenseRepository.addExpense(testExpense)).thenAnswer((_) async => null);

        final result = await expenseService.addExpense(testExpense);

        expect(result, isNull);
        verify(mockExpenseRepository.addExpense(testExpense)).called(1);
      });
    });

    group('updateExpense', () {
      test('should update expense with correct data', () async {
        final updatedExpense = Expense(
          id: 1,
          categoryId: 2,
          amount: 25.0,
          date: DateTime(2024, 1, 5),
          note: 'Updated Note',
        );

        when(mockExpenseRepository.updateExpense(updatedExpense)).thenAnswer((_) async => 1);

        await expenseService.updateExpense(updatedExpense);

        verify(mockExpenseRepository.updateExpense(updatedExpense)).called(1);
      });

      test('should throw exception if update fails', () async {
        when(mockExpenseRepository.updateExpense(testExpense)).thenThrow(Exception('Failed to update'));
        expect(() async => await expenseService.updateExpense(testExpense),
            throwsA(isA<Exception>()));
      });
    });

    group('deleteExpense', () {
      test('should delete expense with correct id', () async {
        final expenseIdToDelete = 1;

        when(mockExpenseRepository.deleteExpense(expenseIdToDelete)).thenAnswer((_) async => 1);

        await expenseService.deleteExpense(expenseIdToDelete);

        verify(mockExpenseRepository.deleteExpense(expenseIdToDelete)).called(1);
      });

      test('should throw exception if delete fails', () async {
        when(mockExpenseRepository.deleteExpense(1)).thenThrow(Exception('Failed to delete'));
        expect(() async => await expenseService.deleteExpense(1),
            throwsA(isA<Exception>()));
      });
    });

    group('calculateTotalExpenses', () {
      test('should calculate total expenses', () async {
        final expenses = [
          testExpense,
          Expense(categoryId: 2, amount: 20.0, date: DateTime(2024, 1, 2), note: 'Test Note'),
        ];

        final total = expenseService.calculateTotalExpenses(expenses);

        expect(total, 30.0);
      });

      test('should return 0 if expenses list is empty', () async {
        final total = expenseService.calculateTotalExpenses([]);

        expect(total, 0.0);
      });
    });
  });
}