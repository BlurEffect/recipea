import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final currentLocale = ref.watch(localeProvider);
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l.settingsTitle),
      ),
      body: ListView(
        children: [
          _SectionHeader(label: l.settingsAppearanceLabel, colors: colors),
          _ThemeTile(
            label: l.settingsThemeSystem,
            icon: Icons.brightness_auto_outlined,
            mode: ThemeMode.system,
            selected: currentMode == ThemeMode.system,
            colors: colors,
          ),
          _ThemeTile(
            label: l.settingsThemeLight,
            icon: Icons.light_mode_outlined,
            mode: ThemeMode.light,
            selected: currentMode == ThemeMode.light,
            colors: colors,
          ),
          _ThemeTile(
            label: l.settingsThemeDark,
            icon: Icons.dark_mode_outlined,
            mode: ThemeMode.dark,
            selected: currentMode == ThemeMode.dark,
            colors: colors,
          ),
          _SectionHeader(label: l.settingsLanguageLabel, colors: colors),
          _LanguageTile(
            label: l.settingsLanguageEn,
            locale: const Locale('en'),
            selected: currentLocale.languageCode == 'en',
            colors: colors,
          ),
          _LanguageTile(
            label: l.settingsLanguageDe,
            locale: const Locale('de'),
            selected: currentLocale.languageCode == 'de',
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.colors});

  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile({
    required this.label,
    required this.icon,
    required this.mode,
    required this.selected,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final ThemeMode mode;
  final bool selected;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(label),
      leading: selected
          ? Icon(Icons.check_circle, color: colors.primary)
          : Icon(icon, color: colors.textSecondary),
      onTap: () => ref.read(themeModeProvider.notifier).setMode(mode),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.selected,
    required this.colors,
  });

  final String label;
  final Locale locale;
  final bool selected;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(label),
      leading: selected
          ? Icon(Icons.check_circle, color: colors.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () => ref.read(localeProvider.notifier).setLocale(locale),
    );
  }
}
