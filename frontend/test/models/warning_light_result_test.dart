import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_part/features/ai_detection/data/models/warning_light_result.dart';

void main() {
  group('WarningLightResult', () {
    test('parses a single identified light correctly', () {
      final json = {
        'identified': true,
        'lights': [
          {
            'name': 'Engine Warning Light',
            'explanation': 'Indicates an engine malfunction.',
            'severity': 'high',
            'action': 'Stop driving and contact a mechanic.',
          }
        ],
      };

      final result = WarningLightResult.fromJson(json);

      expect(result.identified, isTrue);
      expect(result.lights.length, 1);
      expect(result.lights.first.name, 'Engine Warning Light');
      expect(result.lights.first.severity, 'high');
    });

    test('parses multiple lights and preserves order', () {
      final json = {
        'identified': true,
        'lights': [
          {
            'name': 'Engine Warning',
            'explanation': 'Engine issue.',
            'severity': 'high',
            'action': 'Stop immediately.',
          },
          {
            'name': 'Low Fuel',
            'explanation': 'Fuel is low.',
            'severity': 'low',
            'action': 'Refuel soon.',
          },
        ],
      };

      final result = WarningLightResult.fromJson(json);

      expect(result.lights.length, 2);
      expect(result.lights[0].severity, 'high');
      expect(result.lights[1].severity, 'low');
    });

    test('parses unidentified result correctly', () {
      final json = {
        'identified': false,
        'message': 'No warning light visible in the image.',
      };

      final result = WarningLightResult.fromJson(json);

      expect(result.identified, isFalse);
      expect(result.lights, isEmpty);
      expect(result.message, 'No warning light visible in the image.');
    });

    test('returns empty lights list when identified is false', () {
      final result = WarningLightResult.fromJson({
        'identified': false,
        'message': 'Blurry image.',
      });

      expect(result.lights, isEmpty);
    });

    test('handles missing optional fields with defaults', () {
      final json = {
        'identified': true,
        'lights': [
          {
            'name': null,
            'explanation': null,
            'severity': null,
            'action': null,
          }
        ],
      };

      final result = WarningLightResult.fromJson(json);
      final light = result.lights.first;

      expect(light.name, '');
      expect(light.explanation, '');
      expect(light.severity, 'low');
      expect(light.action, '');
    });
  });

  group('WarningLightItem', () {
    test('parses all fields correctly', () {
      final item = WarningLightItem.fromJson({
        'name': 'Battery Warning',
        'explanation': 'Battery is not charging.',
        'severity': 'medium',
        'action': 'Check alternator and battery connections.',
      });

      expect(item.name, 'Battery Warning');
      expect(item.explanation, 'Battery is not charging.');
      expect(item.severity, 'medium');
      expect(item.action, 'Check alternator and battery connections.');
    });
  });
}
