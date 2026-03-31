import 'package:ccpocket/models/machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Machine URLs', () {
    test('defaults to ws/http when SSL is disabled', () {
      const machine = Machine(id: 'm1', host: 'bridge.example.com');

      expect(machine.useSsl, isFalse);
      expect(machine.wsUrl, 'ws://bridge.example.com:8765');
      expect(machine.httpUrl, 'http://bridge.example.com:8765');
    });

    test('uses wss/https when SSL is enabled', () {
      const machine = Machine(
        id: 'm2',
        host: 'bridge.example.com',
        port: 443,
        useSsl: true,
      );

      expect(machine.wsUrl, 'wss://bridge.example.com:443');
      expect(machine.httpUrl, 'https://bridge.example.com:443');
    });
  });

  group('Machine JSON', () {
    test('useSsl defaults to false when missing from stored data', () {
      final machine = Machine.fromJson({
        'id': 'm3',
        'host': 'bridge.example.com',
        'port': 8765,
      });

      expect(machine.useSsl, isFalse);
      expect(machine.wsUrl, 'ws://bridge.example.com:8765');
    });
  });
}
