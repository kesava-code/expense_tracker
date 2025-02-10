import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { home, stats, expenses, notifications }

class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.home); // Initial tab

  void changeTab(AppTab tab) => emit(tab);
}