import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs.dart';

class TextEditor extends StatelessWidget {
  const TextEditor({
    super.key,
    required CodeController asmFileEditorController,
  }) : _asmFileEditorController = asmFileEditorController;

  final CodeController _asmFileEditorController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            fontFamily: 'Courier New',
            fontSize: 16,
          ),
          gutterStyle: GutterStyle.none,
          controller: _asmFileEditorController,
        ),
      ),
    );
  }
}
