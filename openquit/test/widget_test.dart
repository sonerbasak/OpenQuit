import 'package:flutter_test/flutter_test.dart';

import 'package:openquit/features/addiction/domain/entities/addiction.dart';

void main() {
  group('Addiction entity', () {
    late Addiction addiction;

    setUp(() {
      addiction = Addiction(
        id: 'test-id',
        name: 'Smoking',
        iconName: 'smoking',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        costPerDay: 5.0,
        minutesWastedPerDay: 30,
      );
    });

    test('sobrietyDuration is positive', () {
      expect(addiction.sobrietyDuration.inDays, greaterThanOrEqualTo(10));
    });

    test('moneySaved is positive after 10 days at 5.0/day', () {
      expect(addiction.moneySaved, greaterThan(40));
    });

    test('timeSaved is positive after 10 days at 30 min/day', () {
      expect(addiction.timeSaved.inMinutes, greaterThanOrEqualTo(300));
    });

    test('copyWith replaces fields correctly', () {
      final updated = addiction.copyWith(name: 'Alcohol');
      expect(updated.name, 'Alcohol');
      expect(updated.id, addiction.id);
    });
  });
}
