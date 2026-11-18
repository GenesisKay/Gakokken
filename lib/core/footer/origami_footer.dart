// Pie de Ajustes de la serie Herramientas Origami (OR-16).
// Mismo archivo en todas las apps; solo cambia el import del tema.
// Diseño: Origami-Base/diseno/pie.md.

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme_extensions.dart';

/// Nombre de la app con su versión y, debajo, "Hecho por Morobu", que abre
/// morobu.com en el navegador. Va al final de Ajustes.
class OrigamiFooter extends StatelessWidget {
  const OrigamiFooter({
    super.key,
    required this.appName,
    required this.madeByLabel,
  });

  /// Nombre de la app, tal cual (es nombre propio, no se traduce).
  final String appName;

  /// "Hecho por Morobu" desde los `.arb` (clave común `madeByMorobu`).
  final String madeByLabel;

  static const String website = 'https://morobu.com';

  static Future<PackageInfo>? _info;

  /// Versión visible de la app ("2.1.0"), sin el número de compilación.
  static Future<String> version() async {
    _info ??= PackageInfo.fromPlatform();
    try {
      return (await _info!).version;
    } catch (_) {
      return '';
    }
  }

  /// Texto de la primera línea: "Ajoruto 2.1.0", o solo el nombre si la
  /// versión todavía no se lee o no se pudo leer.
  static String nameWithVersion(String appName, String version) =>
      version.isEmpty ? appName : '$appName $version';

  /// Abre morobu.com en el navegador del sistema. La app no necesita permiso
  /// de internet. `utm_source` dice desde qué app llegó la visita.
  static Future<void> openWebsite(String appName) async {
    final uri = Uri.parse(website).replace(queryParameters: {
      'utm_source': appName.toLowerCase(),
      'utm_medium': 'app',
    });
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Sin navegador no hay nada que hacer; el pie no debe tronar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = context.typography.small;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FutureBuilder<String>(
          future: version(),
          builder: (context, snap) => Text(
            nameWithVersion(appName, snap.data ?? ''),
            style: small.copyWith(
              color: colors.textSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Semantics(
          link: true,
          child: TextButton(
            onPressed: () => openWebsite(appName),
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(48, 40),
            ),
            child: Text(
              madeByLabel,
              maxLines: 1,
              softWrap: false,
              style: small.copyWith(color: colors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
