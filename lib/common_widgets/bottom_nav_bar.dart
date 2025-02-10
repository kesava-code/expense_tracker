import 'package:expense_tracker/cubit/navigation_cubit.dart';
import 'package:expense_tracker/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppTab>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            // Use IndexedStack to keep screens alive
            index: state.index, // Use cubit's state for index
            children: const <Widget>[
              HomeScreen(),
              Center(),
              Center(),
              Center(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            useLegacyColorScheme: false,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            elevation: 1,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: state.index, // Use cubit's state for index
            onTap: (index) {
              final tab = AppTab.values[index];
              context.read<NavigationCubit>().changeTab(tab);
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined),
                activeIcon: Icon(Icons.insights_sharp),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money_outlined),
                activeIcon: Icon(Icons.attach_money_sharp),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications_sharp),
                label: '',
              ),
            ],
          ),
        );
      },
    );
  }
}
