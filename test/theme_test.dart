import 'package:flutter_test/flutter_test.dart';
import 'package:gakoken/core/theme/color_extensions.dart';

void main() {
  test('Gakoken is the default theme and Nekokag its dark pair', () {
    final themes = AppColorExtension.builtInThemes;
    expect(themes['default'], same(AppColorExtension.defaultTheme));
    expect(themes['nekokag'], same(AppColorExtension.nekokagTheme));
    expect(themes.containsKey('eloisa'), isTrue);
    expect(
      AppColorExtension.nekokagTheme.bgPrimary.computeLuminance(),
      lessThan(AppColorExtension.defaultTheme.bgPrimary.computeLuminance()),
    );
  });
}
