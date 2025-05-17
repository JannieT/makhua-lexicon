class Entry {
  final String id;
  final String headword;
  final String? partOfSpeech;
  final String definition;
  final String? exampleSentence;
  final List<int> flags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Entry({
    required this.id,
    required this.headword,
    required this.definition,
    required this.createdAt,
    required this.updatedAt,
    this.exampleSentence,
    this.partOfSpeech,
    this.flags = const [],
  });

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
