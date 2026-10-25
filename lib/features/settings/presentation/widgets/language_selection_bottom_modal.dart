import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/widgets/modal_drag_handle.dart';

class LanguageSelectionBottomModal extends StatelessWidget {
  final VoidCallback onLanguageChanged;

  const LanguageSelectionBottomModal({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + gakokenSheetBottomInset(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModalDragHandle(),
          Text(
            AppLocalizations.of(context)!.labelLanguage,
            style: context.typography.modalTitle,
          ),
          const SizedBox(height: 16),
          _buildLanguageOption(context, 'Español', 'es_MX'),
          _buildLanguageOption(context, 'English', 'en_US'),
          _buildLanguageOption(context, '日本語', 'ja'),
          _buildLanguageOption(context, 'Français', 'fr'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    final currentLocale = LocaleService().currentLocale;
    String currentCode = currentLocale.languageCode;
    if (currentLocale.countryCode != null) {
      currentCode += '_${currentLocale.countryCode}';
    }

    final isSelected = currentCode == code;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected
            ? context.colors.primary
            : context.colors.textSecondary,
      ),
      title: Text(
        name,
        style: context.typography.body.copyWith(
          color: isSelected
              ? context.colors.primary
              : context.colors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: context.colors.primary)
          : null,
      onTap: () {
        Locale locale;
        if (code.contains('_')) {
          final parts = code.split('_');
          locale = Locale(parts[0], parts[1]);
        } else {
          locale = Locale(code);
        }

        LocaleService().changeLocale(locale);
        Navigator.pop(context);
        onLanguageChanged();
      },
    );
  }
}
