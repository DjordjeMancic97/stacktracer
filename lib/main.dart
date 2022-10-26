// ignore_for_file: unnecessary_string_escapes

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import 'src/stacktracer_window.dart';

void main() {
  runApp(const StacktracerWindow());
  doWhenWindowReady(() {
    const initialSize = Size(700, 500);
    appWindow.minSize = initialSize;
    appWindow.maxSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Stacktracer';
    appWindow.show();
  });
}
