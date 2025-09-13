import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String id;
  final String headword;
  final String definition;
  final String? exampleSentence;
  final List<int> flags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;

  Entry({
    required this.id,
    required this.headword,
    required this.definition,
    required this.createdAt,
    required this.updatedAt,
    this.exampleSentence,
    this.flags = const [],
    required this.updatedBy,
  });

  static Entry fromJson(Map<String, dynamic> data) {
    return Entry(
      id: data['id'],
      headword: data['headword'],
      definition: data['definition'],
      createdAt: _parseTimestamp(data['created_at']),
      updatedAt: _parseTimestamp(data['updated_at']),
      updatedBy: data['updated_by'],
      exampleSentence: data['example_sentence'],
      flags: _parseFlags(data['flags']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headword': headword,
      'definition': definition,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'updated_by': updatedBy,
      'example_sentence': exampleSentence,
      'flags': flags,
    };
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
