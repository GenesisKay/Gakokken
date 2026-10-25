import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keyboard_dismissible.dart';

class AdvancedHexColorPicker extends StatefulWidget {
  final Color initialColor;
  final double size;
  final Function(Color)? onColorChanged;
  final TextStyle? hexTextStyle;
  final InputDecoration? hexInputDecoration;

  const AdvancedHexColorPicker({
    super.key,
    this.initialColor = Colors.red,
    this.size = 120.0,
    this.onColorChanged,
    this.hexTextStyle,
    this.hexInputDecoration,
  });

  @override
  State<AdvancedHexColorPicker> createState() => _AdvancedHexColorPickerState();
}

class _AdvancedHexColorPickerState extends State<AdvancedHexColorPicker> {
  late double _hue;
  late double _saturation;
  late double _value;
  late Color _selectedColor;
  final TextEditingController _hexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _updateHexController();
  }

  void _updateHexController() {
    _hexController.text = _colorToHex(_selectedColor);
  }

  String _colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).substring(2).toUpperCase();
  }

  Color _hexToColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return _selectedColor;
    } catch (_) {
      return _selectedColor;
    }
  }

  void _updateColor() {
    _selectedColor = HSVColor.fromAHSV(
      1.0,
      _hue,
      _saturation,
      _value,
    ).toColor();
    _updateHexController();
    widget.onColorChanged?.call(_selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Cuadrado de gradiente con indicador
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _saturation = (details.localPosition.dx / widget.size)
                            .clamp(0.0, 1.0);
                        _value =
                            1 -
                            (details.localPosition.dy / widget.size).clamp(
                              0.0,
                              1.0,
                            );
                        _updateColor();
                      });
                    },
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: SaturationValuePainter(_hue),
                        ),
                        // Indicador circular
                        Positioned(
                          left: _saturation * widget.size - 6,
                          top: (1 - _value) * widget.size - 6,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Slider de Hue con gradiente arcoíris
              Container(
                width: 24,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // Gradiente arcoíris de fondo
                      RotatedBox(
                        quarterTurns: -1,
                        child: Container(
                          width: widget.size,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFFFF0000), // Rojo
                                const Color(0xFFFFFF00), // Amarillo
                                const Color(0xFF00FF00), // Verde
                                const Color(0xFF00FFFF), // Cian
                                const Color(0xFF0000FF), // Azul
                                const Color(0xFFFF00FF), // Magenta
                                const Color(0xFFFF0000), // Rojo
                              ],
                              stops: const [
                                0.0,
                                0.17,
                                0.33,
                                0.5,
                                0.67,
                                0.83,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Slider transparente sobre el gradiente
                      RotatedBox(
                        quarterTurns: -1,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _hue,
                            min: 0,
                            max: 360,
                            onChanged: (value) {
                              setState(() {
                                _hue = value;
                                _updateColor();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Campo hexadecimal con preview
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Text(
                          '#',
                          style:
                              widget.hexTextStyle ??
                              TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _hexController,
                          style:
                              widget.hexTextStyle ??
                              TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            hintText: 'FFFFFF',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                          inputFormatters: [
                            UpperCaseTextInputFormatter(),
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9A-Fa-f]'),
                            ),
                            LengthLimitingTextInputFormatter(6),
                          ],
                          onChanged: (value) {
                            if (value.length == 6) {
                              setState(() {
                                _selectedColor = _hexToColor(value);
                                final hsv = HSVColor.fromColor(_selectedColor);
                                _hue = hsv.hue;
                                _saturation = hsv.saturation;
                                _value = hsv.value;
                                widget.onColorChanged?.call(_selectedColor);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Cuadradito de preview del color
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }
}

class SaturationValuePainter extends CustomPainter {
  final double hue;

  SaturationValuePainter(this.hue);

  @override
  void paint(Canvas canvas, Size size) {
    // Gradiente horizontal (Saturación)
    final saturationGradient = LinearGradient(
      colors: [Colors.white, HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor()],
    );

    // Gradiente vertical (Valor/Brightness)
    final valueGradient = LinearGradient(
      colors: [Colors.transparent, Colors.black],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final rect = Offset.zero & size;

    // Pinta saturación
    final saturationPaint = Paint()
      ..shader = saturationGradient.createShader(rect);
    canvas.drawRect(rect, saturationPaint);

    // Aplica valor/brillo
    final valuePaint = Paint()
      ..shader = valueGradient.createShader(rect)
      ..blendMode = BlendMode.multiply;
    canvas.drawRect(rect, valuePaint);
  }

  @override
  bool shouldRepaint(SaturationValuePainter oldDelegate) =>
      oldDelegate.hue != hue;
}

class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
