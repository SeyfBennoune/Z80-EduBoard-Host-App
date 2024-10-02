import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:z80_edu_board/constants.dart';

class ListingFileViewer extends StatelessWidget {
  const ListingFileViewer({
    super.key,
    required CodeController lstFileEditorController,
  }) : _lstFileEditorController = lstFileEditorController;

  final CodeController _lstFileEditorController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CodeTheme(
        data: CodeThemeData(
          styles: monokaiSublimeTheme,
        ),
        child: CodeField(
          expands: true,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(kPaddingUnit),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Courier New', // Use a monospaced font

            fontSize: 12,
          ),
          gutterStyle: GutterStyle.none,
          controller: _lstFileEditorController,
        ),
      ),
    );
  }
}
