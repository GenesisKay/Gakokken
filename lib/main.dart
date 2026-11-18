import 'core/tutorial/origami_tour.dart';
import 'core/tutorial/gakoken_tours.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/engine/file_engine.dart';
import 'core/engine/rust_file_engine.dart';
import 'core/services/storage_volumes_service.dart';
import 'core/storage/hive_bootstrap.dart';
import 'src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La app no tiene permiso de internet: Montserrat sale de
  // assets/google_fonts/ y nunca se descarga (2026-11-06).
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Hive.initFlutter();
  HiveBootstrap.registerAdapters();
  await HiveBootstrap.openCoreBoxes();

  await initializeDateFormatting(null, null);

  await RustLib.init();
  FileEngine.instance = RustFileEngine();
  await StorageVolumesService().start();

  OrigamiTour.store = HiveTourStore();
  runApp(const GakokenApp());
}
