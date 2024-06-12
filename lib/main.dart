// ignore_for_file: unused_field

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/x86asm.dart';
import 'package:intel_hex/intel_hex.dart';
import 'package:path/path.dart' as path;
import 'package:z80_edu_board/constants.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 51, 95, 179)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Z80 EduBoard IDE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _asmFilePath = '';
  String _asmFileParentPath = '';
  String _asmFileContents = '';
  List<String> _memoryContents = [];
  bool _isAssembled = false;
  bool _isConnected = false;
  final _asmFileEditorController = CodeController(
    text: 'just a test', // Initial code
    language: x86Asm,
  );
  final _lstFileEditorController = CodeController(
      text: 'just a test', // Initial code
      language: markdown);
  bool _isFileSaved = true;
  bool _isFileLoaded = false;

  void createNewFile() {}
  void openFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final files = result.files;
    final asmFilePath = files.first.path.toString();
    final asmFile = File(asmFilePath);
    _asmFilePath = asmFilePath;
    final asmFileContents = await asmFile.readAsString();
    setState(() {
      _asmFileEditorController.text = asmFileContents;
      _asmFileParentPath = asmFile.parent.path;
      _asmFileContents = asmFileContents;
      _isFileLoaded = true;
      _isFileSaved = true;
    });
  }

  void saveChanges() {
    final file = File(_asmFilePath);
    file.writeAsString(_asmFileEditorController.fullText);
    _asmFileContents = _asmFileEditorController.text;
    setState(() {
      _isFileSaved = true;
    });
  }

  Future<void> assembleFile() async {
    if (!_isFileSaved) {
      saveChanges();
    }
    try {
      // Execute the ZASM assembler command with the input file
      final result = await Process.run('vasmz80_oldstyle', [
        '-Fihex',
        '-dotdir',
        _asmFilePath,
        '-L',
        '$_asmFileParentPath/${path.basenameWithoutExtension(_asmFilePath)}.lst',
        '-Lns',
        '-o',
        '$_asmFileParentPath/${path.basenameWithoutExtension(_asmFilePath)}.hex'
      ]);

      if (result.exitCode == 0) {
        _showToast(
            context, '**** ASSEMBLY SUCCESSFULL ****\n\n${result.stdout}');
      } else {
        _showToast(context, '**** ASSEMBLY FAILED ****\n${result.stderr}');
      }
    } catch (e) {
      print('Error executing ZASM assembler: $e');
    }

    final lstFile = File(
        '$_asmFileParentPath/${path.basenameWithoutExtension(_asmFilePath)}.lst');
    final lstFileContents = await lstFile.readAsStringSync();
    setState(() {
      _lstFileEditorController.text = lstFileContents;
      _isAssembled = true;
    });
  }

  void uploadProgram() async {
    final hexFile = File(
            '$_asmFileParentPath/${path.basenameWithoutExtension(_asmFilePath)}.hex')
        .readAsStringSync();
    var memoryContentsAsIntelHexFile = IntelHexFile.fromString(hexFile);
    final memorySize = memoryContentsAsIntelHexFile.maxAddress;
    var memoryContentsAsUint8List = Uint8List(memorySize);
    for (final seg in memoryContentsAsIntelHexFile.segments) {
      for (int i = seg.address; i < seg.endAddress; ++i) {
        memoryContentsAsUint8List[i] = seg.byte(i);
      }
    }
    List<String> memoryContents = [];
    memoryContentsAsUint8List.forEach((addressContent) {
      memoryContents.add(addressContent.toRadixString(16));
    });
    _memoryContents = memoryContents;
  }

  void changeSettings() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kPaddingUnit / 2)),
            title: Text("Port Settings"),
            content: Column(
              children: [
                CheckboxListTile(
                  value: false,
                  onChanged: (value) {},
                  title: Text('CRC'),
                )
              ],
            ),
            actionsPadding: EdgeInsets.all(kPaddingUnit * 2),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                    // backgroundColor: Theme.of(ctx).primaryColor,
                    ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  // style: TextStyle(
                  //   color: Colors.white,
                  // ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).primaryColor,
                ),
                onPressed: () {},
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        padding: EdgeInsets.all(8),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.grey[400],
        content: Text(message),
        // action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _asmFileEditorController.addListener(() {
      setState(() {
        if (_asmFileEditorController.text == _asmFileContents) {
          _isFileSaved = true;
        } else {
          _isFileSaved = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _asmFileEditorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _asmFileEditorController.popupController.enabled = false;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        elevation: kPaddingUnit / 4,
        shadowColor: Colors.grey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              style: IconButton.styleFrom(shape: LinearBorder()),
              tooltip: 'New File',
              onPressed: createNewFile,
              icon: const Icon(
                Icons.new_label,
                size: kTooldBarIconSize,
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(shape: LinearBorder()),
              tooltip: 'Open File',
              onPressed: openFile,
              icon: const Icon(
                Icons.folder_open,
                size: kTooldBarIconSize,
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(shape: LinearBorder()),
              tooltip: 'Save',
              onPressed: saveChanges,
              icon: const Icon(
                Icons.save,
                size: kTooldBarIconSize,
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(shape: LinearBorder()),
              tooltip: 'Assemble',
              onPressed: assembleFile,
              icon: const Icon(
                Icons.numbers,
                size: kTooldBarIconSize,
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(shape: LinearBorder()),
              tooltip: 'Upload Program',
              onPressed: uploadProgram,
              icon: const Icon(
                Icons.usb,
                size: kTooldBarIconSize,
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(shape: LinearBorder()),
              tooltip: 'Port Settings',
              onPressed: changeSettings,
              icon: const Icon(
                Icons.settings,
                size: kTooldBarIconSize,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(kPaddingUnit),
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: kPaddingUnit),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CodeTheme(
                        data: CodeThemeData(
                          styles: vsTheme,
                        ),
                        child: CodeField(
                          expands: true,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Courier New', // Use a monospaced font

                            fontSize: 16,
                          ),
                          gutterStyle: GutterStyle.none,
                          controller: _asmFileEditorController,
                        ),
                      ),
                    ),
                    !_isAssembled
                        ? const SizedBox()
                        : const SizedBox(
                            width: kPaddingUnit,
                          ),
                    !_isAssembled
                        ? const SizedBox()
                        : Expanded(
                            child: CodeTheme(
                              data: CodeThemeData(
                                styles: monokaiSublimeTheme,
                              ),
                              child: CodeField(
                                expands: true,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(kPaddingUnit),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily:
                                      'Courier New', // Use a monospaced font

                                  fontSize: 12,
                                ),
                                gutterStyle: GutterStyle.none,
                                controller: _lstFileEditorController,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(kPaddingUnit),
              color: Colors.grey,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '$_asmFilePath${_isFileLoaded ? _isFileSaved ? '' : '*' : ''}'),
                  Text(_isConnected
                      ? 'Z80 EduBoard: Connected.'
                      : 'Z80 EduBoard: Not Connected'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
