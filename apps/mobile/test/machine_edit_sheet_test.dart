import 'package:ccpocket/features/session_list/widgets/machine_edit_sheet.dart';
import 'package:ccpocket/models/machine.dart';
import 'package:ccpocket/services/ssh_startup_service.dart';
import 'package:ccpocket/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    Machine? machine,
    required Future<void> Function({
      required Machine machine,
      String? apiKey,
      String? sshPassword,
      String? sshPrivateKey,
    })
    onSave,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: MachineEditSheet(
            machine: machine,
            onSave: onSave,
            onTestConnection:
                ({
                  required host,
                  required sshPort,
                  required username,
                  required authType,
                  password,
                  privateKey,
                }) async => SshResult.success(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('MachineEditSheet secure connection', () {
    testWidgets('loads existing SSL setting into the toggle', (tester) async {
      await pumpSheet(
        tester,
        machine: const Machine(
          id: 'm1',
          host: 'secure.example.com',
          useSsl: true,
        ),
        onSave:
            ({required machine, apiKey, sshPassword, sshPrivateKey}) async {},
      );

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile).first,
      );
      expect(switchTile.value, isTrue);
    });

    testWidgets('saves useSsl when secure connection is enabled', (
      tester,
    ) async {
      Machine? savedMachine;

      await pumpSheet(
        tester,
        machine: const Machine(id: 'm2', host: 'bridge.example.com'),
        onSave: ({required machine, apiKey, sshPassword, sshPrivateKey}) async {
          savedMachine = machine;
        },
      );

      await tester.tap(find.text('Use secure connection'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedMachine, isNotNull);
      expect(savedMachine!.useSsl, isTrue);
      expect(savedMachine!.wsUrl, 'wss://bridge.example.com:8765');
    });
  });
}
