import 'package:analytics/models/daily_expense.dart';
import 'package:expense_tracker/features/home/bloc/daily_expenses_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import your bloc

class DailyExpensesChart extends StatelessWidget {
  const DailyExpensesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyExpensesBloc, DailyExpensesState>(
      builder: (context, state) {
        if (state is DailyExpensesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DailyExpensesLoaded) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1200,
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: _barTouchData,
                  titlesData: _titlesData,
                  borderData: FlBorderData(show: false),
                  barGroups: _generateBarGroups(state.dailyExpenses),
                  gridData: const FlGridData(show: false),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(state.dailyExpenses),
                ),
              ),
            ),
          );
        } else if (state is DailyExpensesError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text("Initial State"));
        }
      },
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<DailyExpense> dailyExpenses) {
    return List.generate(dailyExpenses.length, (index) {
      final dailyExpense = dailyExpenses[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dailyExpense.totalExpense.toDouble(),
            gradient: const LinearGradient(
              colors: [
                Colors.blue,
                Colors.cyan,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  double _calculateMaxY(List<DailyExpense> dailyExpenses) {
    if (dailyExpenses.isEmpty) return 20;

    double maxY = 0;
    for (var expense in dailyExpenses) {
      if (expense.totalExpense > maxY) {
        maxY = expense.totalExpense;
      }
    }
    return maxY * 1.2;
  }

  BarTouchData get _barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.toString(),
              const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  FlTitlesData get _titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: _getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget _getTitles(double value, TitleMeta meta) {
    final style = const TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text('${value.toInt() + 1}', style: style), // Show day number
    );
  }
}
