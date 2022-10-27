import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stacktracer_service.dart';

class StacktracerWindow extends StatefulWidget {
  const StacktracerWindow({super.key});

  @override
  State<StacktracerWindow> createState() => _StacktracerWindowState();
}

class _StacktracerWindowState extends State<StacktracerWindow> {
  PlatformFile? _selectedSymbols;
  String _stacktraceShow = '';
  String _flutterExecutable = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('flutterPath')?.isEmpty ?? true) {
        String? flutterPath = await FilePicker.platform
            .getDirectoryPath(dialogTitle: 'Select Flutter bin folder');
        _flutterExecutable = flutterPath ?? '';
        prefs.setString('flutterPath', flutterPath ?? '');
      } else {
        _flutterExecutable = prefs.getString('flutterPath')!;
      }
    });
  }

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
                            Container(
                              width: double.infinity,
                              child: SelectableText(
                                '$_stacktraceShow\n\n\n',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
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
                        onPressed: _stacktraceShow.isEmpty ||
                                _selectedSymbols == null
                            ? null
                            : () async {
                                try {
                                  String obfuscateResult =
                                      await StacktracerService().deobfuscate(
                                          _flutterExecutable,
                                          _stacktraceShow,
                                          _selectedSymbols!.path!);

                                  setState(() {
                                    _stacktraceShow = obfuscateResult;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _stacktraceShow = e.toString();
                                  });
                                }
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
