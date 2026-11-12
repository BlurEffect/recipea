import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/settings_sheet.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l.navMore,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      body: ListView(
        children: [
          _MoreTile(
            icon: Icons.eco_outlined,
            label: l.achievementsTitle,
            onTap: () => context.push('/achievements'),
          ),
          const Divider(height: 1, indent: 56),
          _MoreTile(
            icon: Icons.settings_outlined,
            label: l.settingsTitle,
            onTap: () => showSettingsSheet(context),
          ),
          const Divider(height: 1, indent: 56),
          _MoreTile(
            icon: Icons.privacy_tip_outlined,
            label: l.moreDataProtection,
            onTap: () => context.push('/legal/data-protection'),
          ),
          const Divider(height: 1, indent: 56),
          _MoreTile(
            icon: Icons.info_outline,
            label: l.moreImprint,
            onTap: () => context.push('/legal/imprint'),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
