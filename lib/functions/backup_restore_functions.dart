// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tswiri_base/functions/create_backup.dart';
import 'package:tswiri_base/functions/restore_backup.dart';
import 'package:tswiri_base/settings/app_settings.dart';
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/mobile_database.dart';

///Creates a backup (.zip) of the current Space.
///
/// - On success returns the file.
/// - On fails it returns null.
///
Future<File?> createBackupFile({
  required ValueNotifier<double> progressNotifier,
  required String fileName,
}) async {
  FlutterIsolate? _isolate;
  ReceivePort _uiPort = ReceivePort();

  //Temporary Directory.
  Directory temporaryDirectory = await getTemporaryDirectory();

  _isolate = await FlutterIsolate.spawn(
    createBackup,
    [
      _uiPort.sendPort,
      isarDirectory!.path,
      temporaryDirectory.path,
      isarVersion.toString(),
      photoDirectory!.path,
      fileName,
    ],
  );

  var completer = Completer<File>();

  _uiPort.listen((message) {
    switch (message[0]) {
      case 'done':
        killIsolate(_isolate);
        break;
      case 'path':
        completer.complete(File(message[1].toString()));
        break;
      case 'progress':
        progressNotifier.value = message[1] as double;
        break;
      default:
    }
  });

  return completer.future;
}

///Restores a backup file to the current Space.
Future<bool?> restoreBackupFile({
  required ValueNotifier<double> progressNotifier,
  required File backupFile,
}) async {
  FlutterIsolate? _isolate;
  ReceivePort _uiPort = ReceivePort();

  log(photoDirectory!.path, name: 'Photo Directory');
  log(isarDirectory!.path, name: 'Isar Directory');

  if (isar!.isOpen) {
    await isar!.close();
  }

  //Temporary Directory.
  Directory temporaryDirectory = await getTemporaryDirectory();

  _isolate = await FlutterIsolate.spawn(
    restoreBackup,
    [
      _uiPort.sendPort,
      isarDirectory!.path,
      temporaryDirectory.path,
      isarVersion.toString(),
      photoDirectory!.path,
      backupFile.path,
      (await getExternalStorageDirectory())!.path,
    ],
  );

  var completer = Completer<bool>();

  _uiPort.listen((message) {
    if (message[0] == 'done') {
      completer.complete(true);
      killIsolate(_isolate);
    } else if (message[0] == 'error') {
      switch (message[1]) {
        case 'file_error':
          log('file_error');
          killIsolate(_isolate);
          completer.complete(false);
          break;
        default:
      }
    } else if (message[0] == 'progress') {
      progressNotifier.value = message[1] as double;
    }
  });

  return completer.future;
}

///Kills an isolate and re-opens isar.
void killIsolate(FlutterIsolate? isolate) {
  if (isolate != null) {
    isolate.kill();
  }
  if (!isar!.isOpen) {
    isar = initiateMobileIsar(inspector: true, directory: isarDirectory!.path);
    log('opening isar');
  }
}

String generateBackupFileName() {
  String spaceName = isarDirectory!.path.split('/').last;
  String formattedDate = DateFormat('_yyyy_MM_dd').format(DateTime.now());

  return spaceName + formattedDate;
}
