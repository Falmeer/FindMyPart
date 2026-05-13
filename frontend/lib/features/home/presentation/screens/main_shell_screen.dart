import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

final _shellIndexProvider = StateProvider<int>((ref) => 0);

class MainShellScreen extends ConsumerWidget {
  final Widget child;
  const MainShellScreen({super.key, required this.child});

  static const _tabs = [
    (path: '/', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (path: '/vehicles', icon: Icons.directions_car_outlined, activeIcon: Icons.directions_car, label: 'Vehicles'),
    (path: '/parts', icon: Icons.build_outlined, activeIcon: Icons.build_rounded, label: 'Parts'),
    (path: '/garages', icon: Icons.car_repair, activeIcon: Icons.car_repair, label: 'Garages'),
    (path: '/issues', icon: Icons.forum_outlined, activeIcon: Icons.forum_rounded, label: 'Issues'),
    (path: '/profile', icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_shellIndexProvider);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(_shellIndexProvider.notifier).state = index;
          context.go(_tabs[index].path);
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon, color: AppColors.primary),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
