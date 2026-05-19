import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'help_faq_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProfileHeader(name: user?.name ?? '', role: user?.role ?? '', email: user?.email ?? ''),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'My Activity',
            tiles: [
              _Tile(Icons.favorite_border, 'Favorites', () => context.push('/favorites')),
              _Tile(Icons.chat_bubble_outline_rounded, 'Messages', () => context.push('/conversations')),
              _Tile(Icons.notifications_outlined, 'Notifications', () => context.push('/notifications')),
              if (user?.isCustomer == true)
                _Tile(Icons.report_problem_outlined, 'My Issues', () => context.push('/my-issues')),
              if (user?.isGarage == true || user?.isYardOwner == true)
                _Tile(Icons.list_alt_rounded, 'Customer Issues', () => context.push('/open-issues')),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Settings',
            tiles: [
              _Tile(Icons.person_outline, 'Edit Profile', () => context.push('/profile/edit')),
              _Tile(Icons.lock_outline, 'Change Password', () => context.push('/profile/change-password')),
              _Tile(Icons.dark_mode_outlined, 'Appearance', () {}),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Support',
            tiles: [
              _Tile(Icons.help_outline, 'Help & FAQ', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqScreen()))),
              _Tile(Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
              _Tile(Icons.info_outline, 'About FindMyPart', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'FindMyPart v1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(authStateProvider.notifier).logout();
      }
    });
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  const _ProfileHeader({required this.name, required this.role, required this.email});

  @override
  Widget build(BuildContext context) {
    final roleLabel = role == 'garage'
        ? 'Garage Owner'
        : role == 'yard_owner'
            ? 'Yard Owner'
            : 'Customer';

    return Row(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(email,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(roleLabel,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_Tile> tiles;
  const _SectionCard({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: tiles.map((t) {
              final isLast = t == tiles.last;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(t.icon, size: 22, color: AppColors.textPrimary),
                    title: Text(t.label, style: const TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
                    onTap: t.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Tile {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tile(this.icon, this.label, this.onTap);
}
