import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:meepmrp_client/preferences.dart';
import 'package:meepmrp_client/widget/home.dart';
import 'package:one_context/one_context.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:openapi/api.dart';

Future<void> main() async {

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  //await runZonedGuarded<Future<void>>(
  //  () async {
  //    WidgetsFlutterBinding.ensureInitialized();
  //    PackageInfo info = await PackageInfo.fromPlatform();
  //    String pkg = info.packageName;
  //    String version = info.version;
  //    String build = info.buildNumber;

  //    String release = "${pkg}@${version}:${build}";

  //    // TODO: Sentry?

  //    // TODO: pass errors to sentry

  //    final int orientation = await SettingsManager().getValue(
  //      SCREEN_ORIENTATION,
  //      SCREEN_ORIENTATION_SYSTEM
  //    );

  //    List<DeviceOrientation> orientations = [];
  //    switch (orientation) {
  //      case SCREEN_ORIENTATION_PORTRAIT:
  //        orientations.add(DeviceOrientation.portraitUp);
  //        break;
  //      case SCREEN_ORIENTATION_LANDSCAPE:
  //        orientations.add(DeviceOrientation.landscapeLeft);
  //        break;
  //      default:
  //        orientations.add(DeviceOrientation.portraitUp);
  //        //orientations.add(DeviceOrientation.portraitDown);
  //        orientations.add(DeviceOrientation.landscapeLeft);
  //        orientations.add(DeviceOrientation.landscapeRight);
  //        break;
  //    }

  //    SystemChrome.setPreferredOrientations(orientations).then(
  //      (_) {
  //        runApp(MeepMrpApp(savedThemeMode));
  //      }
  //    );
  //  },
  //  (Object error, StackTrace stackTrace) async {
  //    // TODO: report error to sentry or something
  //  }
  //);
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo info = await PackageInfo.fromPlatform();
  String pkg = info.packageName;
  String version = info.version;
  String build = info.buildNumber;

  String release = "${pkg}@${version}:${build}";

  // TODO: Sentry?

  // TODO: pass errors to sentry

  final int orientation = await SettingsManager().getValue(
    SCREEN_ORIENTATION,
    SCREEN_ORIENTATION_SYSTEM
  );

  List<DeviceOrientation> orientations = [];
  switch (orientation) {
    case SCREEN_ORIENTATION_PORTRAIT:
      orientations.add(DeviceOrientation.portraitUp);
      break;
    case SCREEN_ORIENTATION_LANDSCAPE:
      orientations.add(DeviceOrientation.landscapeLeft);
      break;
    default:
      orientations.add(DeviceOrientation.portraitUp);
      //orientations.add(DeviceOrientation.portraitDown);
      orientations.add(DeviceOrientation.landscapeLeft);
      orientations.add(DeviceOrientation.landscapeRight);
      break;
  }

  SystemChrome.setPreferredOrientations(orientations).then(
    (_) {
      runApp(MeepMrpApp(savedThemeMode));
    }
  );
}

class MeepMrpApp extends StatefulWidget {
  const MeepMrpApp(this.savedThemeMode);

  final AdaptiveThemeMode? savedThemeMode;

  @override
  State<StatefulWidget> createState() => MeepMrpAppState(savedThemeMode);

  static MeepMrpAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MeepMrpAppState>();
  }
}

class MeepMrpAppState extends State<StatefulWidget> {
  MeepMrpAppState(this.savedThemeMode) : super();

  //Locale? _locale;

  final AdaptiveThemeMode? savedThemeMode;

  @override
  void initState() {
    super.initState();

    runInitTasks();
  }

  Future<void> runInitTasks() async {
    // TODO: set locale?

    // TODO: check version?

  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.lightBlue,
        secondaryHeaderColor: Colors.blueGrey
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.lightBlue,
        secondaryHeaderColor: Colors.blueGrey
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.dark,
      builder: (light, dark) => MaterialApp(
        theme: light,
        darkTheme: dark,
        //debugShowCheckedModeBanner: false,
        builder: OneContext().builder,
        navigatorKey: OneContext().key,
        onGenerateTitle: (BuildContext context) => "MeepMRP",
        home: HomePage(),
        // localizationDelegates: []
        // supportedLocales: supported_locales,
        // locale: _locale
      ),
    );
  }

}
