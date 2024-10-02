import 'package:flutter/material.dart';
import 'package:z80_edu_board/constants.dart';

class BottomTab extends StatelessWidget {
  const BottomTab({
    super.key,
    required String asmFilePath,
    required bool isFileLoaded,
    required bool isFileSaved,
    required bool isConnected,
  })  : _asmFilePath = asmFilePath,
        _isFileLoaded = isFileLoaded,
        _isFileSaved = isFileSaved,
        _isConnected = isConnected;

  final String _asmFilePath;
  final bool _isFileLoaded;
  final bool _isFileSaved;
  final bool _isConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kPaddingUnit),
      color: Colors.grey,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$_asmFilePath${_isFileLoaded ? _isFileSaved ? '' : '*' : ''}'),
          Text(_isConnected
              ? 'Z80 EduBoard: Connected.'
              : 'Z80 EduBoard: ${_isConnected ? 'Connected' : 'Not Connected'}'),
        ],
      ),
    );
  }
}
