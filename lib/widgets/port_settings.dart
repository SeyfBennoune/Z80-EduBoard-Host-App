import 'package:flutter/material.dart';
import 'package:z80_edu_board/constants.dart';

class PortSettings extends StatelessWidget {
  const PortSettings({
    super.key,
    required this.settingsControllers,
    required this.settings,
  });

  final Map<String, TextEditingController> settingsControllers;
  final Map<String, dynamic> settings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownMenu(
            controller: settingsControllers['Port'],
            label: Text('Port'),
            initialSelection: settings['Port'],
            dropdownMenuEntries: <DropdownMenuEntry<String>>[
              DropdownMenuEntry(value: 'COM1', label: 'COM1'),
              DropdownMenuEntry(value: 'COM2', label: 'COM2'),
              DropdownMenuEntry(value: 'COM3', label: 'COM3'),
              DropdownMenuEntry(value: 'COM4', label: 'COM4'),
            ]),
        SizedBox(
          width: kPaddingUnit * 4,
        ),
        DropdownMenu(
            controller: settingsControllers['Baud Rate'],
            label: Text('Baud Rate'),
            initialSelection: settings['Baud Rate'],
            dropdownMenuEntries: <DropdownMenuEntry<int>>[
              DropdownMenuEntry(value: 2400, label: '2400'),
              DropdownMenuEntry(value: 4800, label: '4800'),
              DropdownMenuEntry(value: 9600, label: '9600'),
              DropdownMenuEntry(value: 19200, label: '19200'),
              DropdownMenuEntry(value: 38400, label: '38400'),
              DropdownMenuEntry(value: 57600, label: '57600'),
              DropdownMenuEntry(value: 115200, label: '115200'),
            ]),
        SizedBox(
          width: kPaddingUnit * 4,
        ),
        DropdownMenu(
          controller: settingsControllers['Parity'],
          label: Text('Parity'),
          initialSelection: settings['Parity'],
          dropdownMenuEntries: <DropdownMenuEntry<String>>[
            DropdownMenuEntry(value: 'NONE', label: 'NONE'),
            DropdownMenuEntry(value: 'EVEN', label: 'EVEN'),
            DropdownMenuEntry(value: 'ODD', label: 'ODD'),
          ],
        ),
        SizedBox(
          width: kPaddingUnit * 4,
        ),
        DropdownMenu(
          controller: settingsControllers['Stop Bits'],
          label: Text('Stop Bits'),
          initialSelection: settings['Stop Bits'],
          dropdownMenuEntries: <DropdownMenuEntry<int>>[
            DropdownMenuEntry(value: 1, label: '1'),
            DropdownMenuEntry(value: 2, label: '2'),
          ],
        ),
      ],
    );
  }
}
