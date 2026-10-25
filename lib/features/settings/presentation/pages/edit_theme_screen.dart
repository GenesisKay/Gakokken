import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/color_extensions.dart';
import '../../../../core/theme/models/app_theme_data.dart';
import '../../../../core/theme/theme_generator.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
// Importar picker de color si existe, o usar uno básico
import '../../../../core/widgets/advanced_hex_color_picker.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/keyboard_dismissible.dart';

class EditThemeScreen extends StatefulWidget {
  final AppThemeData? themeToEdit;

  const EditThemeScreen({super.key, this.themeToEdit});

  @override
  State<EditThemeScreen> createState() => _EditThemeScreenState();
}

class _EditThemeScreenState extends State<EditThemeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _themeService = ThemeService();

  // Mapa temporal de colores
  late Map<String, int> _colors;

  // Magic Generator State
  Color _seedColor = const Color(0xFF7B5EA7); // Default Seed
  Brightness _targetBrightness = Brightness.light;
  bool _useSecondary = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.themeToEdit != null) {
      _nameController.text = widget.themeToEdit!.name;
      _descriptionController.text = widget.themeToEdit!.description;
      _colors = Map.from(widget.themeToEdit!.colors);

      // Checar si usa secundarios
      if (_colors.containsKey('secondary')) {
        _useSecondary = true;
      }
    } else {
      // Iniciar con colores default
      _colors = {};
      _initializeDefaultColors();
    }
  }

  void _initializeDefaultColors() {
    // Cargar defaults desde AppColorExtension.defaultTheme
    final def = AppColorExtension.defaultTheme;
    _updateColorsFromExtension(def);
  }

  void _updateColorsFromExtension(AppColorExtension ext) {
    setState(() {
      _colors['bgPrimary'] = ext.bgPrimary.value;
      _colors['bgSecondary'] = ext.bgSecondary.value;
      _colors['bgElevated'] = ext.bgElevated.value;
      _colors['overlay'] = ext.overlay.value;

      _colors['textPrimary'] = ext.textPrimary.value;
      _colors['textSecondary'] = ext.textSecondary.value;
      _colors['textDisabled'] = ext.textDisabled.value;
      _colors['textInverse'] = ext.textInverse.value;

      _colors['borderSubtle'] = ext.borderSubtle.value;
      _colors['borderFocus'] = ext.borderFocus.value;

      _colors['primary'] = ext.primary.value;
      _colors['primaryHover'] = ext.primaryHover.value;
      _colors['primaryActive'] = ext.primaryActive.value;

      _colors['surfaceHover'] = ext.surfaceHover.value;
      _colors['surfaceActive'] = ext.surfaceActive.value;

      _colors['stateSuccess'] = ext.stateSuccess.value;
      _colors['stateWarning'] = ext.stateWarning.value;
      _colors['stateError'] = ext.stateError.value;
      _colors['stateInfo'] = ext.stateInfo.value;

      // Generar secundarios si es necesario, o limpiar
      if (_useSecondary || ext.rawSecondary != null) {
        _useSecondary = true;
        _colors['secondary'] = ext.secondary.value;
        _colors['secondaryHover'] = ext.secondaryHover.value;
        _colors['secondaryActive'] = ext.secondaryActive.value;
      }
    });
  }

  void _generateFromSeed() {
    final generated = ThemeGenerator.generateFromSeed(
      seed: _seedColor,
      brightness: _targetBrightness,
    );
    _updateColorsFromExtension(generated);

    // Si la interfaz de usuario tenía el toggle apagado, limpiamos los secondary generados
    // para que sigan al primario (a menos que el usuario quiera explícitamente secundarios)
    if (!_useSecondary) {
      _colors.remove('secondary');
      _colors.remove('secondaryHover');
      _colors.remove('secondaryActive');
    }
  }

  Future<void> _saveTheme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Limpieza final: si _useSecondary es falso, borrar claves para ahorrar espacio
    if (!_useSecondary) {
      _colors.remove('secondary');
      _colors.remove('secondaryHover');
      _colors.remove('secondaryActive');
    }

    final id = widget.themeToEdit?.id ?? const Uuid().v4();
    final newTheme = AppThemeData(
      id: id,
      name: _nameController.text,
      description: _descriptionController.text,
      isSystem: false,
      colors: _colors,
    );

    await _themeService.saveTheme(newTheme);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: GakokenAppBar(
        title: widget.themeToEdit == null
            ? AppLocalizations.of(context)!.themeCreateTitle
            : AppLocalizations.of(context)!.themeEditTitle,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveTheme,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            tooltip: AppLocalizations.of(context)!.btnSave,
          ),
        ],
      ),
      body: KeyboardDismissible(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMagicGenerator(),
                const SizedBox(height: 24),
                _buildBasicInfo(),
                const SizedBox(height: 24),
                _buildColorSections(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMagicGenerator() {
    return Card(
      color: context.colors.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.primary.withOpacity(0.3)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.themeGeneratorTitle,
                  style: context.typography.cardTitle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.themeSeedColor,
                        style: context.typography.inputLabel,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          Color temp = _seedColor;
                          await showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              content: SingleChildScrollView(
                                child: AdvancedHexColorPicker(
                                  initialColor: _seedColor,
                                  onColorChanged: (c) => temp = c,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: Text(
                                    AppLocalizations.of(context)!.btnOK,
                                  ),
                                ),
                              ],
                            ),
                          ).then((_) {
                            setState(() => _seedColor = temp);
                          });
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: _seedColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.colors.borderSubtle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.themeBrightness,
                        style: context.typography.inputLabel,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<Brightness>(
                        segments: const [
                          ButtonSegment(
                            value: Brightness.light,
                            icon: Icon(Icons.light_mode),
                          ),
                          ButtonSegment(
                            value: Brightness.dark,
                            icon: Icon(Icons.dark_mode),
                          ),
                        ],
                        selected: {_targetBrightness},
                        onSelectionChanged: (s) =>
                            setState(() => _targetBrightness = s.first),
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _generateFromSeed,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.themeGenerateAction),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.textInverse,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.themeNameLabel,
              labelStyle: context.typography.inputLabel,
              fillColor: context.colors.bgSecondary,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) => v?.isEmpty == true
                ? AppLocalizations.of(context)!.themeRequired
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.themeDescLabel,
              labelStyle: context.typography.inputLabel,
              fillColor: context.colors.bgSecondary,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSections() {
    return Column(
      children: [
        _buildExpansionTile(AppLocalizations.of(context)!.themeSectionCore, [
          _buildColorSection(
            AppLocalizations.of(context)!.themeSectionBackgrounds,
            [
              _buildColorPicker(
                'bgPrimary',
                AppLocalizations.of(context)!.colorBgPrimary,
              ),
              _buildColorPicker(
                'bgSecondary',
                AppLocalizations.of(context)!.colorBgSecondary,
              ),
              _buildColorPicker(
                'bgElevated',
                AppLocalizations.of(context)!.colorBgElevated,
              ),
              _buildColorPicker(
                'overlay',
                AppLocalizations.of(context)!.colorOverlay,
              ),
            ],
          ),
          _buildColorSection(AppLocalizations.of(context)!.themeSectionTexts, [
            _buildColorPicker(
              'textPrimary',
              AppLocalizations.of(context)!.colorTextPrimary,
            ),
            _buildColorPicker(
              'textSecondary',
              AppLocalizations.of(context)!.colorTextSecondary,
            ),
            _buildColorPicker(
              'textDisabled',
              AppLocalizations.of(context)!.colorTextDisabled,
            ),
            _buildColorPicker(
              'textInverse',
              AppLocalizations.of(context)!.colorTextInverse,
            ),
          ]),
        ]),

        const SizedBox(height: 16),

        _buildExpansionTile(AppLocalizations.of(context)!.themeSectionBrand, [
          _buildColorSection(
            AppLocalizations.of(context)!.themeSectionPrimary,
            [
              _buildColorPicker(
                'primary',
                AppLocalizations.of(context)!.colorPrimary,
              ),
              _buildColorPicker(
                'primaryHover',
                AppLocalizations.of(context)!.colorPrimaryHover,
              ),
              _buildColorPicker(
                'primaryActive',
                AppLocalizations.of(context)!.colorPrimaryActive,
              ),
            ],
          ),

          ListTile(
            title: Text(
              AppLocalizations.of(context)!.themeUseSecondary,
              style: context.typography.cardTitle,
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.themeUseSecondaryDesc,
              style: context.typography.small,
            ),
            trailing: Switch(
              value: _useSecondary,
              activeThumbColor: context.colors.primary,
              onChanged: (val) {
                setState(() {
                  _useSecondary = val;
                  if (val) {
                    // Populate with current primary if empty
                    _colors['secondary'] ??= _colors['primary']!;
                    _colors['secondaryHover'] ??= _colors['primaryHover']!;
                    _colors['secondaryActive'] ??= _colors['primaryActive']!;
                  }
                });
              },
            ),
          ),

          if (_useSecondary)
            _buildColorSection(
              AppLocalizations.of(context)!.themeSectionSecondary,
              [
                _buildColorPicker(
                  'secondary',
                  AppLocalizations.of(context)!.colorSecondary,
                ),
                _buildColorPicker(
                  'secondaryHover',
                  AppLocalizations.of(context)!.colorSecondaryHover,
                ),
                _buildColorPicker(
                  'secondaryActive',
                  AppLocalizations.of(context)!.colorSecondaryActive,
                ),
              ],
            ),
        ]),

        const SizedBox(height: 16),

        _buildExpansionTile(AppLocalizations.of(context)!.themeSectionUI, [
          _buildColorSection(AppLocalizations.of(context)!.themeSectionStates, [
            _buildColorPicker(
              'stateSuccess',
              AppLocalizations.of(context)!.colorStateSuccess,
            ),
            _buildColorPicker(
              'stateWarning',
              AppLocalizations.of(context)!.colorStateWarning,
            ),
            _buildColorPicker(
              'stateError',
              AppLocalizations.of(context)!.colorStateError,
            ),
            _buildColorPicker(
              'stateInfo',
              AppLocalizations.of(context)!.colorStateInfo,
            ),
          ]),
          _buildColorSection(
            AppLocalizations.of(context)!.themeSectionComponents,
            [
              _buildColorPicker(
                'borderSubtle',
                AppLocalizations.of(context)!.colorBorderSubtle,
              ),
              _buildColorPicker(
                'borderFocus',
                AppLocalizations.of(context)!.colorBorderFocus,
              ),
              _buildColorPicker(
                'surfaceHover',
                AppLocalizations.of(context)!.colorSurfaceHover,
              ),
              _buildColorPicker(
                'surfaceActive',
                AppLocalizations.of(context)!.colorSurfaceActive,
              ),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _buildExpansionTile(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: ExpansionTile(
        title: Text(title, style: context.typography.cardTitle),
        shape: const Border(), // Remove borders when expanded
        childrenPadding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }

  Widget _buildColorSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.typography.inputLabel.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: children),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildColorPicker(String key, String label) {
    final colorValue = _colors[key] ?? 0xFF000000;
    final color = Color(colorValue);

    return InkWell(
      onTap: () async {
        Color tempColor = color;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.themeSelectColorTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdvancedHexColorPicker(
                    initialColor: color,
                    onColorChanged: (newColor) {
                      tempColor = newColor;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.btnCancel),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _colors[key] = tempColor.value;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.btnSelect),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 140, // Slightly smaller
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.borderSubtle),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: context.typography.small.copyWith(
                  color: context.colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
