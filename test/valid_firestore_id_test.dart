import 'package:flutter_test/flutter_test.dart';
import 'package:makhua_lexicon/src/shared/models/entry.dart';

void main() {
  group('getValidFirestoreId', () {
    test('handles empty string', () {
      final id = Entry.getValidFirestoreId('');
      expect(id.startsWith('empty-id-'), isTrue);
      expect(id.length > 10, isTrue);
    });

    test('normalizes diacritical marks', () {
      expect(Entry.getValidFirestoreId('áéíóú'), equals('aeiou'));
      expect(Entry.getValidFirestoreId('ñ'), equals('n'));
      expect(Entry.getValidFirestoreId('çãõêâ'), equals('caoea'));
    });

    test('converts to lowercase', () {
      expect(Entry.getValidFirestoreId('AbCdEf'), equals('abcdef'));
      expect(Entry.getValidFirestoreId('UPPER'), equals('upper'));
    });

    test('replaces spaces with hyphens', () {
      expect(Entry.getValidFirestoreId('hello world'), equals('hello-world'));
      expect(Entry.getValidFirestoreId('multiple   spaces'), equals('multiple-spaces'));
    });

    test('removes special characters', () {
      expect(Entry.getValidFirestoreId('hello!@#world'), equals('helloworld'));

      // Empty result should generate an ID with timestamp
      final emptyResult = Entry.getValidFirestoreId('\$%^&*()');
      expect(emptyResult.startsWith('id-'), isTrue);
      expect(emptyResult.length > 3, isTrue);
    });

    test('handles forward slashes', () {
      expect(Entry.getValidFirestoreId('path/to/document'), equals('path-to-document'));
    });

    test('handles consecutive periods', () {
      expect(Entry.getValidFirestoreId('test..document'), equals('test.document'));
      expect(
        Entry.getValidFirestoreId('multiple......periods'),
        equals('multiple.periods'),
      );
    });

    test('trims periods from start and end', () {
      expect(Entry.getValidFirestoreId('.test'), equals('test'));
      expect(Entry.getValidFirestoreId('test.'), equals('test'));
      expect(Entry.getValidFirestoreId('.test.'), equals('test'));
    });

    test('handles exact "." or ".."', () {
      expect(Entry.getValidFirestoreId('.'), equals('dot'));
      expect(Entry.getValidFirestoreId('..'), equals('dot'));
    });

    test('limits length for very long strings', () {
      final longString = 'a' * 200;
      final id = Entry.getValidFirestoreId(longString);
      expect(id.length, equals(100));
    });

    test('handles problematic real-world examples', () {
      expect(Entry.getValidFirestoreId('café au lait'), equals('cafe-au-lait'));
      expect(
        Entry.getValidFirestoreId('joão document/folder'),
        equals('joao-document-folder'),
      );
      expect(
        Entry.getValidFirestoreId('joão\'s document/folder'),
        equals('joaos-document-folder'),
      );
      expect(
        Entry.getValidFirestoreId('O\'Reilly & Associates'),
        equals('oreilly-associates'),
      );
      expect(Entry.getValidFirestoreId('multiple---hyphens'), equals('multiple-hyphens'));
    });

    test('handles Portuguese characters correctly', () {
      expect(Entry.getValidFirestoreId('João'), equals('joao'));
      expect(Entry.getValidFirestoreId('ação'), equals('acao'));
      expect(Entry.getValidFirestoreId('Não'), equals('nao'));
    });
  });
}
