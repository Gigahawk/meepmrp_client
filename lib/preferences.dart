import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

const String SCREEN_ORIENTATION = "appScreenOrientation";
const int SCREEN_ORIENTATION_SYSTEM = 0;
const int SCREEN_ORIENTATION_PORTRAIT = 1;
const int SCREEN_ORIENTATION_LANDSCAPE = 2;

const String NULL_STR = "__null__";

class SettingsDatabase {
  SettingsDatabase._();

  static final SettingsDatabase _singleton = SettingsDatabase._();
  static SettingsDatabase get instance => _singleton;

  Completer<Database> _dbOpenCompleter = Completer();

  bool isOpen = false;
  Future<Database> get database async {
    if (!isOpen) {
      _openDatabase();
      isOpen = true;
    }

    return _dbOpenCompleter.future;
  }

  Future<void> _openDatabase() async {
    Database database;
    if (kIsWeb) {
      database = await databaseFactoryWeb.openDatabase("MeepMrpDB");
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentDir.path, "MeepMRPSettings.db");
      database = await databaseFactoryIo.openDatabase(dbPath);
    }
    _dbOpenCompleter.complete(database);
  }
}

class SettingsManager {
  // Internal constructor
  SettingsManager._internal();
  // Singleton instance
  static final SettingsManager _manager = SettingsManager._internal();

  factory SettingsManager() {
    return _manager;
  }

  final store = StoreRef("settings");

  Future<Database> get _db async => SettingsDatabase.instance.database;

  Future<dynamic> getValue(String key, dynamic defaultVal) async {
    dynamic value = await store.record(key).get(await _db);
    if (value == NULL_STR) {
      value = null;
    }
    if (value  == null) {
      return defaultVal;
    }
    return value;
  }

  // Load a boolean setting
  Future<bool> getBool(String key, bool backup) async {
    final dynamic value = await getValue(key, backup);

    if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase().contains("t");
    } else {
      return false;
    }
  }

  Future<void> setValue(String key, dynamic value) async {
    // Encode null values as strings
    value ??= NULL_STR;
    await store.record(key).put(await _db, value);
  }

}