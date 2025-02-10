import 'package:analytics/services/analytics_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_client/expenses_client.dart'; 

// States
abstract class RecentExpensesState {}
class RecentExpensesInitial extends RecentExpensesState {}
class RecentExpensesLoading extends RecentExpensesState {}
class RecentExpensesLoaded extends RecentExpensesState {
  final List<ExpenseCategory> recentExpenses;

  RecentExpensesLoaded(this.recentExpenses);
}
class RecentExpensesError extends RecentExpensesState {
  final String message;

  RecentExpensesError(this.message);
}

// Cubit
class RecentExpensesCubit extends Cubit<RecentExpensesState> {
  final AnalyticsService _analyticsService;

  RecentExpensesCubit({AnalyticsService? analyticsService})
      : _analyticsService = analyticsService ?? AnalyticsService(),
        super(RecentExpensesInitial());

  Future<void> loadRecentExpenses(int limit) async {
    emit(RecentExpensesLoading());
    try {
      final recentExpenses = await _analyticsService.getRecentExpenses(limit);
      emit(RecentExpensesLoaded(recentExpenses));
    } catch (e) {
      emit(RecentExpensesError(e.toString()));
    }
  }
}