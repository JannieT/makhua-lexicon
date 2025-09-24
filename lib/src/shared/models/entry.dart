import 'package:cloud_firestore/cloud_firestore.dart';

import 'translation.dart';

class Entry {
  // metadata
  final String id;
  final List<int> flags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;

  // makhua
  final String headword;
  final String? inflections;
  final String definition;
  final String? exampleSentence;

  // translations
  final Translation? portugueseTranslation;
  final Translation? englishTranslation;

  Entry({
    required this.id,
    required this.headword,
    required this.definition,
    required this.createdAt,
    required this.updatedAt,
    this.exampleSentence,
    this.flags = const [],
    required this.updatedBy,
    this.inflections,
    this.portugueseTranslation,
    this.englishTranslation,
  });

  static Entry fromJson(Map<String, dynamic> data) {
    return Entry(
      id: data['id'],
      headword: data['headword'],
      inflections: data['inflections'],
      definition: data['definition'],
      createdAt: _parseTimestamp(data['created_at']),
      updatedAt: _parseTimestamp(data['updated_at']),
      updatedBy: data['updated_by'],
      exampleSentence: data['example_sentence'],
      flags: _parseFlags(data['flags']),
      portugueseTranslation: Translation.fromJson(data['portuguese_translation']),
      englishTranslation: Translation.fromJson(data['english_translation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headword': headword,
      'inflections': inflections,
      'definition': definition,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'updated_by': updatedBy,
      'example_sentence': exampleSentence,
      'flags': flags,
      'portuguese_translation': portugueseTranslation?.toJson(),
      'english_translation': englishTranslation?.toJson(),
    };
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        // Fallback to current time if string parsing fails
        return DateTime.now();
      }
    } else {
      // Fallback to current time if timestamp is invalid
      return DateTime.now();
    }
  }

  static List<int> _parseFlags(dynamic flags) {
    if (flags == null) return [];
    if (flags is List) {
      return flags.map((flag) {
        if (flag is int) return flag;
        if (flag is String) return int.tryParse(flag) ?? 0;
        return 0; // fallback for any other type
      }).toList();
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    if (other is Entry) {
      return id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;

  /// Parses a comma-separated string into a list of trimmed, non-empty strings
  static List<String> parseCommaSeparatedString(String? value) {
    if (value == null || value.isEmpty) return [];
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// Gets inflections as a list of strings
  List<String> get inflectionsList => parseCommaSeparatedString(inflections);

  /// Gets portuguese headwords as a list of strings
  List<String> get portugueseHeadwordsList =>
      parseCommaSeparatedString(portugueseTranslation?.headwords);

  /// Gets english headwords as a list of strings
  List<String> get englishHeadwordsList =>
      parseCommaSeparatedString(englishTranslation?.headwords);

  /// Creates a copy of this Entry with the given fields replaced with new values.
  Entry copyWith({
    String? id,
    List<int>? flags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
    String? headword,
    String? inflections,
    String? definition,
    String? exampleSentence,
    Translation? portugueseTranslation,
    Translation? englishTranslation,
  }) {
    return Entry(
      id: id ?? this.id,
      flags: flags ?? this.flags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      headword: headword ?? this.headword,
      inflections: inflections ?? this.inflections,
      definition: definition ?? this.definition,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      portugueseTranslation: portugueseTranslation ?? this.portugueseTranslation,
      englishTranslation: englishTranslation ?? this.englishTranslation,
    );
  }

  /// Transforms a string to a valid Firestore document ID.
  ///
  /// This method:
  /// - Normalizes diacritical marks (accents)
  /// - Converts to lowercase
  /// - Replaces spaces and non-alphanumeric chars with hyphens
  /// - Removes invalid characters (/, periods that would create ..)
  /// - Ensures the ID doesn't start or end with a period
  /// - Trims to a reasonable length
  static String getValidFirestoreId(String text) {
    // Special case handling for empty string, "." or ".."
    if (text.isEmpty || text == '.' || text == '..') {
      return text.isEmpty ? 'empty-id-${DateTime.now().millisecondsSinceEpoch}' : 'dot';
    }

    // Simple direct replacements for common Portuguese characters
    String normalized = text
        .replaceAll('ã', 'a')
        .replaceAll('Ã', 'a')
        .replaceAll('õ', 'o')
        .replaceAll('Õ', 'o')
        .replaceAll('ê', 'e')
        .replaceAll('Ê', 'e')
        .replaceAll('á', 'a')
        .replaceAll('Á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('É', 'e')
        .replaceAll('í', 'i')
        .replaceAll('Í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('Ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('Ú', 'u')
        .replaceAll('â', 'a')
        .replaceAll('Â', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('Ô', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll('Ñ', 'n')
        .replaceAll('\'', '') // Remove apostrophes
        .replaceAll('&', ''); // Remove ampersands

    // Convert to lowercase, replace spaces and special chars with hyphens
    String result = normalized
        .toLowerCase()
        .replaceAll('/', '-') // Replace forward slashes with hyphens first
        .replaceAll(
          RegExp(r'[^\w\s\-\.]'),
          '',
        ) // Remove special chars except spaces, letters, numbers, hyphens, and periods
        .replaceAll(RegExp(r'\s+'), '-'); // Replace spaces with hyphens

    // Handle periods - remove consecutive periods
    while (result.contains('..')) {
      result = result.replaceAll('..', '.');
    }

    // Ensure no consecutive hyphens
    while (result.contains('--')) {
      result = result.replaceAll('--', '-');
    }

    // Remove leading and trailing special characters
    result = result.trim();
    if (result.startsWith('-') || result.startsWith('.')) {
      result = result.substring(1);
    }
    if (result.endsWith('-') || result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }

    // Handle special case for "." or ".." (after processing)
    if (result == '.' || result == '..') {
      result = 'dot';
    }

    // Add timestamp if empty result after all processing
    if (result.isEmpty) {
      result = 'id-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Limit to a reasonable length
    if (result.length > 100) {
      result = result.substring(0, 100);
    }

    // Handle empty result
    if (result.isEmpty) {
      result = 'id-${DateTime.now().millisecondsSinceEpoch}';
    }

    return result;
  }
}
