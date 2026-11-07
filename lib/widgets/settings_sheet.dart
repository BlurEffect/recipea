import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.settingsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                l.settingsLanguageLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _LanguageTile(
              label: l.settingsLanguageEn,
              locale: const Locale('en'),
              selected: currentLocale.languageCode == 'en',
            ),
            _LanguageTile(
              label: l.settingsLanguageDe,
              locale: const Locale('de'),
              selected: currentLocale.languageCode == 'de',
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.selected,
  });

  final String label;
  final Locale locale;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(label),
      leading: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }
}
