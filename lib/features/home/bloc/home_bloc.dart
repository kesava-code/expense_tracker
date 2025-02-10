import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/home/data/home_repository.dart'; // Import your repository

// Define events
abstract class HomeEvent {}
class HomeStarted extends HomeEvent {}
// ... other events

// Define states
abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final dynamic data; // Replace with your data type

  HomeLoaded(this.data);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository; // Inject repository

  HomeBloc({HomeRepository? homeRepository}) :
        _homeRepository = homeRepository ?? HomeRepository(),
        super(HomeInitial()) {
    on<HomeStarted>((event, emit) async {
      emit(HomeLoading());
      try {
        final data = await _homeRepository.fetchHomeData(); // Use repository
        emit(HomeLoaded(data));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    // ... handle other events
  }
}