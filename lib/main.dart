// ignore_for_file: unnecessary_string_escapes

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stacktracer/src/deobfuscator_service.dart';

void main() {
  runApp(const MyApp());
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PlatformFile? _selectedSymbols;
  String _stacktraceShow = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xff455A64),
        body: WindowBorder(
          color: const Color(0xff009688),
          width: 3,
          child: Column(
            children: [
              WindowTitleBarBox(
                child: MoveWindow(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Spacer(),
                      MinimizeWindowButton(
                          colors: WindowButtonColors(iconNormal: Colors.white)),
                      CloseWindowButton(
                          colors: WindowButtonColors(iconNormal: Colors.white)),
                    ],
                  ),
                ),
              ),
              const Text(
                'Stacktracer',
                style: TextStyle(
                  fontFamily: 'PerfectDark',
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xff607D8B),
                        ),
                        child: Stack(
                          children: [
                            SelectableText(
                              '$_stacktraceShow\n\n\n',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _stacktraceShow.isEmpty
                                                  ? Colors.grey
                                                  : const Color(0xff009688)),
                                    ),
                                    onPressed: () async {
                                      await FlutterClipboard.copy(
                                          _stacktraceShow);

                                      setState(() {});
                                    },
                                    child: const Text('Copy'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color(0xff009688)),
                                    ),
                                    onPressed: () async {
                                      _stacktraceShow =
                                          await FlutterClipboard.paste();
                                      setState(() {});
                                    },
                                    child: const Text('Paste'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xff009688)),
                        ),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  dialogTitle: 'Select deobfuscation symbols',
                                  allowedExtensions: ['symbols']);

                          if (result != null &&
                              result.files.single.path != null) {
                            setState(() {
                              _selectedSymbols = result.files.single;
                            });
                          }
                        },
                        child: const Text(
                          'Select deobfuscation symbols',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 26),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              _stacktraceShow.isEmpty ||
                                      _selectedSymbols == null
                                  ? Colors.grey
                                  : const Color(0xff009688)),
                        ),
                        onPressed:
                            _stacktraceShow.isEmpty || _selectedSymbols == null
                                ? null
                                : () async {
                                    String obfuscateResult =
                                        await DeobfuscatorService().deobfuscate(
                                            _stacktraceShow,
                                            _selectedSymbols!.path!);

                                    setState(() {
                                      _stacktraceShow = obfuscateResult;
                                    });
                                  },
                        child: const Text('Deobfusacate'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
