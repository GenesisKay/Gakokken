import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/services/platform_detection_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/color_extensions.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../widgets/theme_card.dart';
import '../widgets/theme_options_bottom_modal.dart';
import '../widgets/delete_theme_bottom_modal.dart';
import 'edit_theme_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/keyboard_dismissible.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.titleImportTheme,
          style: context.typography.modalTitle,
        ),
        content: KeyboardDismissible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.instructionImportTheme,
                style: context.typography.body,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      '{ "version": "1.0", ... }', // Code example, keep as is
                  filled: true,
                  fillColor: context.colors.bgSecondary,
                ),
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      AppLocalizations.of(context)!.themeImportOr,
                      style: context.typography.small,
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final success = await _themeService.pickFileAndImport();
                    if (success && mounted) {
                      Navigator.pop(c);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.themeImportFileSuccess,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.themeImportError(e.toString()),
                          ),
                          backgroundColor: context.colors.stateError,
                        ),
                      );
                    }
                  }
                },
                icon: Icon(Icons.folder_open),
                label: Text(AppLocalizations.of(context)!.themeSelectJson),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text(AppLocalizations.of(context)!.btnCancel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    if (controller.text.isEmpty) return;
                    try {
                      final newId = await _themeService.importThemeFromJson(
                        controller.text,
                      );
                      if (mounted) {
                        Navigator.pop(c);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.msgThemeImportSuccess,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.errorPrefix +
                                  e.toString(),
                            ),
                            backgroundColor: context.colors.stateError,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.btnImport),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportTheme(String themeId, {bool saveToFile = false}) async {
    try {
      final jsonStr = _themeService.exportThemeToJson(themeId);
      final fileName = 'gakoken_theme_$themeId.json';

      if (saveToFile) {
        final platformInfo = await PlatformDetectionService().getPlatformInfo();

        if (platformInfo.isWeb) {
          await Clipboard.setData(ClipboardData(text: jsonStr));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.themeCopiedClipboard,
                ),
              ),
            );
          }
        } else if (platformInfo.isDesktop) {
          // Lógica específica para Escritorio (Save Dialog)
          final String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: AppLocalizations.of(context)!.themeSaveTitle,
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['json'],
          );

          if (outputFile != null) {
            final file = File(outputFile);
            await file.writeAsString(jsonStr);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.themeSavedFile(outputFile),
                  ),
                ),
              );
            }
          }
        } else {
          // Lógica para Móvil (Android/iOS) - Guardar en carpeta seleccionada
          // Usamos getDirectoryPath para emular "Guardar en..."
          final String? directoryPath = await FilePicker.platform
              .getDirectoryPath(
                dialogTitle: AppLocalizations.of(
                  context,
                )!.themeSelectFolderTitle,
              );

          if (directoryPath != null) {
            final file = File('$directoryPath/$fileName');
            await file.writeAsString(jsonStr);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.themeSavedFile(file.path),
                  ),
                ),
              );
            }
          } else {
            // User cancelled folder picker.
          }
        }
      } else {
        // Copy to Clipboard (Existing logic)
        await Clipboard.setData(ClipboardData(text: jsonStr));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.themeCopiedClipboard),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.themeExportError(e.toString()),
            ),
            backgroundColor: context.colors.stateError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lista combinada: Default + Personalizados
    final defaults = [
      _AppThemeWrapper(
        id: 'default',
        name: AppLocalizations.of(context)!.themeDefaultName,
        description: AppLocalizations.of(context)!.themeDefaultDescription,
        colors: AppColorExtension.defaultTheme,
      ),
      _AppThemeWrapper(
        id: 'nekokag',
        name: AppLocalizations.of(context)!.themeNameNekokag,
        description: AppLocalizations.of(context)!.themeDescNekokag,
        colors: AppColorExtension.nekokagTheme,
      ),
      _AppThemeWrapper(
        id: 'eloisa',
        name: AppLocalizations.of(context)!.themeNameEloisa,
        description: AppLocalizations.of(context)!.themeDescEloisa,
        colors: AppColorExtension.eloisaTheme,
      ),
      _AppThemeWrapper(
        id: 'asiole',
        name: AppLocalizations.of(context)!.themeDefaultName8,
        description: AppLocalizations.of(context)!.themeDefaultDescription8,
        colors: AppColorExtension.asioleTheme,
      ),
      _AppThemeWrapper(
        id: 'ajoruto',
        name: AppLocalizations.of(context)!.themeDefaultName7,
        description: AppLocalizations.of(context)!.themeDefaultDescription7,
        colors: AppColorExtension.ajorutoTheme,
      ),
      _AppThemeWrapper(
        id: 'oturoja',
        name: AppLocalizations.of(context)!.themeDefaultName2,
        description: AppLocalizations.of(context)!.themeDefaultDescription2,
        colors: AppColorExtension.oturojaTheme,
      ),
      _AppThemeWrapper(
        id: 'manubu',
        name: AppLocalizations.of(context)!.themeDefaultName3,
        description: AppLocalizations.of(context)!.themeDefaultDescription3,
        colors: AppColorExtension.manubuTheme,
      ),
      _AppThemeWrapper(
        id: 'ubunam',
        name: AppLocalizations.of(context)!.themeDefaultName4,
        description: AppLocalizations.of(context)!.themeDefaultDescription4,
        colors: AppColorExtension.ubunamTheme,
      ),
      _AppThemeWrapper(
        id: 'zontle',
        name: AppLocalizations.of(context)!.themeDefaultName5,
        description: AppLocalizations.of(context)!.themeDefaultDescription5,
        colors: AppColorExtension.zontleTheme,
      ),
      _AppThemeWrapper(
        id: 'eltnoz',
        name: AppLocalizations.of(context)!.themeDefaultName6,
        description: AppLocalizations.of(context)!.themeDefaultDescription6,
        colors: AppColorExtension.eltnozTheme,
      ),
      _AppThemeWrapper(
        id: 'bioka',
        name: AppLocalizations.of(context)!.themeNameBioka,
        description: AppLocalizations.of(context)!.themeDescBioka,
        colors: AppColorExtension.biokaTheme,
      ),
      _AppThemeWrapper(
        id: 'akoib',
        name: AppLocalizations.of(context)!.themeNameAkoib,
        description: AppLocalizations.of(context)!.themeDescAkoib,
        colors: AppColorExtension.akoibTheme,
      ),
    ];

    final customThemes = _themeService
        .getAvailableThemes()
        .map(
          (t) => _AppThemeWrapper(
            id: t.id,
            name: t.name,
            description: t.description,
            // Reconvertir mapa a extension para visualizar
            colors: AppColorExtension(
              bgPrimary: Color(t.colors['bgPrimary']!),
              bgSecondary: Color(t.colors['bgSecondary']!),
              bgElevated: Color(t.colors['bgElevated']!),
              overlay: Color(t.colors['overlay']!),
              textPrimary: Color(t.colors['textPrimary']!),
              textSecondary: Color(t.colors['textSecondary']!),
              textDisabled: Color(t.colors['textDisabled']!),
              textInverse: Color(t.colors['textInverse']!),
              borderSubtle: Color(t.colors['borderSubtle']!),
              borderFocus: Color(t.colors['borderFocus']!),
              primary: Color(t.colors['primary']!),
              primaryHover: Color(t.colors['primaryHover']!),
              primaryActive: Color(t.colors['primaryActive']!),
              surfaceHover: Color(t.colors['surfaceHover']!),
              surfaceActive: Color(t.colors['surfaceActive']!),
              stateSuccess: Color(t.colors['stateSuccess']!),
              stateWarning: Color(t.colors['stateWarning']!),
              stateError: Color(t.colors['stateError']!),
              stateInfo: Color(t.colors['stateInfo']!),
              secondary: t.colors.containsKey('secondary')
                  ? Color(t.colors['secondary']!)
                  : null,
            ),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: GakokenAppBar(
        title: AppLocalizations.of(context)!.themesTitle,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            tooltip: AppLocalizations.of(context)!.titleImportTheme,
            onPressed: _showImportDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EditThemeScreen()),
          );
        },
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.textInverse,
        elevation: 4,
        tooltip: AppLocalizations.of(context)!.themeCreateTitle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 30),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)!.headerThemesDefault,
            style: context.typography.sectionHeader,
          ),
          const SizedBox(height: 12),
          ...defaults.map(
            (t) => _ThemeItem(
              theme: t,
              isActive: _themeService.activeThemeId == t.id,
              onTap: () => _themeService.selectTheme(t.id),
              onExport: () => _exportTheme(t.id, saveToFile: false),
              onExportFile: () => _exportTheme(t.id, saveToFile: true),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            AppLocalizations.of(context)!.headerThemesCustom,
            style: context.typography.sectionHeader,
          ),
          const SizedBox(height: 12),
          if (customThemes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.themeEmptyCustom,
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ),

          ...customThemes.map(
            (t) => _ThemeItem(
              theme: t,
              isActive: _themeService.activeThemeId == t.id,
              onTap: () => _themeService.selectTheme(t.id),
              onEdit: () {
                // Buscar el objeto AppThemeData real
                final data = _themeService.getAvailableThemes().firstWhere(
                  (element) => element.id == t.id,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditThemeScreen(themeToEdit: data),
                  ),
                );
              },
              onDelete: () {
                showGakokenBottomSheet(
                  context: context,
                  showDragHandle: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (c) => DeleteThemeBottomModal(
                    themeName: t.name,
                    onConfirmDelete: () {
                      _themeService.deleteTheme(t.id);
                    },
                  ),
                );
              },
              onExport: () => _exportTheme(t.id, saveToFile: false),
              onExportFile: () => _exportTheme(t.id, saveToFile: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  final _AppThemeWrapper theme;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onExport;
  final VoidCallback onExportFile;

  const _ThemeItem({
    required this.theme,
    required this.isActive,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    required this.onExport,
    required this.onExportFile,
  });

  void _showOptions(BuildContext context) {
    showGakokenBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => ThemeOptionsBottomModal(
        themeId: theme.id,
        themeName: theme.name,
        themeDescription: theme.description,
        isActive: isActive,
        isSystem: AppColorExtension.builtInThemes.containsKey(theme.id),
        onApply: onTap,
        onEdit: onEdit,
        onDelete: onDelete,
        onExportJson: onExport,
        onExportFile: onExportFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeCard(
      name: theme.name,
      description: theme.description,
      isActive: isActive,
      primary: theme.colors.primary,
      background: theme.colors.bgPrimary,
      surface: theme.colors.bgElevated,
      onTap: () => _showOptions(context), // Tap opens options as requested
      onMore: () => _showOptions(context),
    );
  }
}

class _AppThemeWrapper {
  final String id;
  final String name;
  final String description;
  final AppColorExtension colors;

  _AppThemeWrapper({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
  });
}
