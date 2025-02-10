import 'package:expense_tracker/features/home/cubit/recent_expenses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RecentExpenses extends StatelessWidget {
  const RecentExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentExpensesCubit, RecentExpensesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Expenses',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (state is RecentExpensesLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is RecentExpensesLoaded)
              state.recentExpenses.isEmpty
                  ? const Text('No recent expenses.')
                  : Column(
                      children: state.recentExpenses
                          .map((expense) => ExpenseItem(
                                title: expense.note,
                                date: DateFormat('MMM dd').format(expense.date),
                                amount:
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                category: expense.categoryName,
                              ))
                          .toList(),
                    )
            else if (state is RecentExpensesError)
              Center(child: Text('Error: ${state.message}'))
            else
              const SizedBox.shrink(), // Initial state - nothing to show
          ],
        );
      },
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String category;

  const ExpenseItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 5),
              Text(
                date,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                category,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
