import 'dart:io';

import 'package:flutter/material.dart' show StringCharacters;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

class StacktracerService {
  Future<String> deobfuscate(
      String obfuscatedStacktraceInput, String selectedSymbolsPath) async {
    String? flutterExectutable = whichSync('flutter');
    if (flutterExectutable == null) {
      return 'Flutter not found';
    }

    String obfuscatedStacktrace = obfuscatedStacktraceInput;

    if (int.tryParse(obfuscatedStacktrace.trim().characters.first) != null) {
      obfuscatedStacktrace =
          tryToConvertContentToStacktrace(obfuscatedStacktrace);
    }
    final tempDir = await getTemporaryDirectory();
    File tempStacktrace = File('${tempDir.path}/stacktrace.txt');
    await tempStacktrace.writeAsString(obfuscatedStacktrace);

    Shell shell = Shell();

    List<ProcessResult> result = await shell.run(
        'flutter symbolize -i "${tempStacktrace.path}" -d "$selectedSymbolsPath"');

    return result.first.outText;
  }

  String tryToConvertContentToStacktrace(String alternativeStacktraceInput) {
    String completeDartIsolateInstructions = '';
    List<String> rawTextInput = alternativeStacktraceInput
        .split(' ')
        .where((element) =>
            element.startsWith('_kDartIsolateSnapshotInstructions'))
        .toList();
    List<String> isolateInstructions = [];

    for (int i = 0; i < rawTextInput.length; i++) {
      for (String snapshotFullLine in rawTextInput[i].split('\n')) {
        if (snapshotFullLine.startsWith('_kDartIsolateSnapshot')) {
          isolateInstructions.add(snapshotFullLine);
        }
      }
    }

    for (int i = 0; i < isolateInstructions.length; i++) {
      if (i < 10) {
        completeDartIsolateInstructions +=
            '$i  ???                            0x0 (null).    #0$i abs 0 ${isolateInstructions[i]}\n';
      } else {
        completeDartIsolateInstructions +=
            '$i  ???                            0x0 (null).    #$i abs 0 ${isolateInstructions[i]}\n';
      }
    }
    return completeDartIsolateInstructions;
  }
}
