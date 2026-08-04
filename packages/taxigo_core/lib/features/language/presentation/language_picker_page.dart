import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/supported_locales.dart';
import '../application/language_bloc.dart';

/// Grid-based language picker for TaxiGo apps.
class LanguagePickerPage extends StatelessWidget {
  const LanguagePickerPage({
    super.key,
    this.onContinue,
    this.showContinueButton = false,
  });

  final VoidCallback? onContinue;
  final bool showContinueButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectLanguage)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, state) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: SupportedLocales.all.length,
                    itemBuilder: (context, index) {
                      final entry = SupportedLocales.all[index];
                      final isSelected = state.locale.languageCode ==
                          entry.locale.languageCode;

                      return _LanguageTile(
                        entry: entry,
                        isSelected: isSelected,
                        isLight: isLight,
                        onTap: () {
                          context.read<LanguageBloc>().add(
                                ChangeLanguage(entry.locale),
                              );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            if (showContinueButton) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onContinue,
                child: Text(l10n.continueButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.entry,
    required this.isSelected,
    required this.isLight,
    required this.onTap,
  });

  final SupportedLocale entry;
  final bool isSelected;
  final bool isLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.primary
        : (isLight ? AppColors.dividerLight : AppColors.dividerDark);

    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (entry.flag.isNotEmpty)
                Text(entry.flag, style: const TextStyle(fontSize: 28)),
              if (entry.flag.isNotEmpty) const SizedBox(height: 8),
              Text(
                entry.nativeName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : null,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                entry.displayName,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
