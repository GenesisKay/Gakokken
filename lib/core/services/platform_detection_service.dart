import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Lightweight platform detection for theme export and similar shell features.
class PlatformDetectionService {
  static final PlatformDetectionService _instance =
      PlatformDetectionService._internal();
  factory PlatformDetectionService() => _instance;
  PlatformDetectionService._internal();

  PlatformInfo? _cached;

  Future<PlatformInfo> getPlatformInfo() async {
    if (_cached != null) return _cached!;

    if (kIsWeb) {
      _cached = const PlatformInfo(
        platform: 'web',
        isWeb: true,
        isMobile: false,
        isDesktop: true,
        supportsFilePicker: true,
        supportsDownloads: true,
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      _cached = PlatformInfo(
        platform: Platform.isAndroid ? 'android' : 'ios',
        isWeb: false,
        isMobile: true,
        isDesktop: false,
        supportsFilePicker: true,
        supportsDownloads: true,
      );
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final name = Platform.isWindows
          ? 'windows'
          : Platform.isMacOS
          ? 'macos'
          : 'linux';
      _cached = PlatformInfo(
        platform: name,
        isWeb: false,
        isMobile: false,
        isDesktop: true,
        supportsFilePicker: true,
        supportsDownloads: true,
      );
    } else {
      _cached = const PlatformInfo(
        platform: 'unknown',
        isWeb: false,
        isMobile: false,
        isDesktop: false,
        supportsFilePicker: false,
        supportsDownloads: false,
      );
    }

    return _cached!;
  }

  void clearCache() => _cached = null;
}

class PlatformInfo {
  final String platform;
  final bool isWeb;
  final bool isMobile;
  final bool isDesktop;
  final bool supportsFilePicker;
  final bool supportsDownloads;

  const PlatformInfo({
    required this.platform,
    required this.isWeb,
    required this.isMobile,
    required this.isDesktop,
    required this.supportsFilePicker,
    required this.supportsDownloads,
  });
}
