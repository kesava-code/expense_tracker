import 'package:expense_tracker/features/home/bloc/daily_expenses_bloc.dart';
import 'package:expense_tracker/features/home/view/recent_expenses.dart';
import 'package:expense_tracker/features/home/view/daily_expenses_chart.dart';
import 'package:expense_tracker/features/home/view/summary_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DailyExpensesBloc>(
      create: (context) =>
          DailyExpensesBloc()..add(LoadDailyExpenses(DateTime.now())),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Hi, Jack',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 20),
                  SummaryCard(
                    title: 'Highest',
                    content: 'Amazon \$150',
                    onTap: () {
                      // Handle highest expense tap
                    },
                  ),
                  const SizedBox(height: 5),
                  SummaryCard(
                    title: 'Total',
                    content: 'Spent 1,230',
                    onTap: () {
                      // Handle total expense tap
                    },
                  ),
                  const SizedBox(height: 20),
                  DailyExpensesChart(),
                  const SizedBox(height: 20),
                  RecentExpenses(),
                  OutlinedButton(
                      onPressed: () {}, child: Center(child: Text("View More")))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
