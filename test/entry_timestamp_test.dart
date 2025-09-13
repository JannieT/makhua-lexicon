import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhua_lexicon/src/shared/models/entry.dart';

void main() {
  group('Entry.fromJson timestamp parsing', () {
    test('handles Firestore Timestamp objects correctly', () {
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      final data = {
        'id': 'test-id',
        'headword': 'test',
        'definition': 'test definition',
        'created_at': timestamp,
        'updated_at': timestamp,
        'updated_by': 'test@example.com',
        'example_sentence': 'test sentence',
        'flags': [1, 2],
      };

      final entry = Entry.fromJson(data);

      expect(entry.id, equals('test-id'));
      expect(entry.headword, equals('test'));
      expect(entry.definition, equals('test definition'));
      expect(entry.createdAt, equals(now));
      expect(entry.updatedAt, equals(now));
      expect(entry.updatedBy, equals('test@example.com'));
      expect(entry.exampleSentence, equals('test sentence'));
      expect(entry.flags, equals([1, 2]));
    });

    test('handles DateTime objects correctly', () {
      final now = DateTime.now();

      final data = {
        'id': 'test-id',
        'headword': 'test',
        'definition': 'test definition',
        'created_at': now,
        'updated_at': now,
        'updated_by': 'test@example.com',
      };

      final entry = Entry.fromJson(data);

      expect(entry.createdAt, equals(now));
      expect(entry.updatedAt, equals(now));
    });

    test('handles string timestamps correctly', () {
      final now = DateTime.now();
      final isoString = now.toIso8601String();

      final data = {
        'id': 'test-id',
        'headword': 'test',
        'definition': 'test definition',
        'created_at': isoString,
        'updated_at': isoString,
        'updated_by': 'test@example.com',
      };

      final entry = Entry.fromJson(data);

      expect(entry.createdAt.year, equals(now.year));
      expect(entry.createdAt.month, equals(now.month));
      expect(entry.createdAt.day, equals(now.day));
      expect(entry.updatedAt.year, equals(now.year));
      expect(entry.updatedAt.month, equals(now.month));
      expect(entry.updatedAt.day, equals(now.day));
    });

    test('handles invalid timestamps gracefully', () {
      final data = {
        'id': 'test-id',
        'headword': 'test',
        'definition': 'test definition',
        'created_at': null,
        'updated_at': 'invalid-date',
        'updated_by': 'test@example.com',
      };

      final entry = Entry.fromJson(data);

      // Should fallback to current time
      expect(entry.createdAt, isA<DateTime>());
      expect(entry.updatedAt, isA<DateTime>());
    });

    test('toJson converts DateTime back to Timestamp', () {
      final now = DateTime.now();
      final entry = Entry(
        id: 'test-id',
        headword: 'test',
        definition: 'test definition',
        createdAt: now,
        updatedAt: now,
        updatedBy: 'test@example.com',
        exampleSentence: 'test sentence',
        flags: [1, 2],
      );

      final json = entry.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['headword'], equals('test'));
      expect(json['definition'], equals('test definition'));
      expect(json['created_at'], isA<Timestamp>());
      expect(json['updated_at'], isA<Timestamp>());
      expect(json['updated_by'], equals('test@example.com'));
      expect(json['example_sentence'], equals('test sentence'));
      expect(json['flags'], equals([1, 2]));

      // Verify timestamp conversion
      expect((json['created_at'] as Timestamp).toDate(), equals(now));
      expect((json['updated_at'] as Timestamp).toDate(), equals(now));
    });

    test('handles flags parsing correctly', () {
      final data = {
        'id': 'test-id',
        'headword': 'test',
        'definition': 'test definition',
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
        'updated_by': 'test@example.com',
        'flags': [1, 2, 3], // List<dynamic> from Firestore
      };

      final entry = Entry.fromJson(data);
      expect(entry.flags, equals([1, 2, 3]));
    });

    test('handles flags with mixed types gracefully', () {
      final data = {
        'id': 'test-id',
        'headword': 'test',
        'definition': 'test definition',
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
        'updated_by': 'test@example.com',
        'flags': [1, '2', 3, 'invalid'], // Mixed types
      };

      final entry = Entry.fromJson(data);
      expect(entry.flags, equals([1, 2, 3, 0])); // 'invalid' becomes 0
    });

    test('handles null or missing flags', () {
      final data = {
        'id': 'test-id',
        'headword': 'test',
        'definition': 'test definition',
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
        'updated_by': 'test@example.com',
        // flags field is missing
      };

      final entry = Entry.fromJson(data);
      expect(entry.flags, equals([]));
    });
  });
}
