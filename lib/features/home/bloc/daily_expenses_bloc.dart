import 'package:analytics/models/daily_expense.dart';
import 'package:analytics/services/analytics_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
// Events
abstract class DailyExpensesEvent {}
class LoadDailyExpenses extends DailyExpensesEvent {
  final DateTime date; // The month for which to load expenses

  LoadDailyExpenses(this.date);
}

// States
abstract class DailyExpensesState {}
class DailyExpensesInitial extends DailyExpensesState {}
class DailyExpensesLoading extends DailyExpensesState {}
class DailyExpensesLoaded extends DailyExpensesState {
  final List<DailyExpense> dailyExpenses;

  DailyExpensesLoaded(this.dailyExpenses);
}
class DailyExpensesError extends DailyExpensesState {
  final String message;

  DailyExpensesError(this.message);
}

class DailyExpensesBloc extends Bloc<DailyExpensesEvent, DailyExpensesState> {
  final AnalyticsService _analyticsService;

  DailyExpensesBloc({AnalyticsService? analyticsService})
      : _analyticsService = analyticsService ?? AnalyticsService(),
        super(DailyExpensesInitial()) {
    on<LoadDailyExpenses>((event, emit) async {
      emit(DailyExpensesLoading());
      try {
        final dailyExpenses =
            await _analyticsService.getDailyExpensesForMonth(event.date);
        emit(DailyExpensesLoaded(dailyExpenses));
      } catch (e) {
        emit(DailyExpensesError(e.toString()));
      }
    });
  }
}