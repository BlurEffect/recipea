import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';

class DataProtectionScreen extends StatelessWidget {
  const DataProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l.moreDataProtection)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          l.legalDataProtectionPlaceholder,
          style: TextStyle(
            fontSize: 15,
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
