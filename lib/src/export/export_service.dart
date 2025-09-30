import 'dart:developer';

import '../shared/models/entry.dart';

class ExportService {
  /// Converts a list of entries to CSV format
  static String entriesToCsv(List<Entry> entries) {
    try {
      final csvBuffer = StringBuffer();

      // Add CSV header
      csvBuffer.writeln('headword,definition,example_sentence');

      // Add entries
      for (final entry in entries) {
        final headword = _escapeCsvField(entry.headword);
        final definition = _escapeCsvField(entry.definition);
        final exampleSentence = _escapeCsvField(entry.exampleSentence ?? '');

        csvBuffer.writeln('$headword,$definition,$exampleSentence');
      }

      return csvBuffer.toString();
    } catch (e) {
      log('Error converting entries to CSV: $e');
      rethrow;
    }
  }

  /// Escapes a field for CSV format
  static String _escapeCsvField(String field) {
    // If the field contains comma, newline, or quote, wrap it in quotes
    if (field.contains(',') || field.contains('\n') || field.contains('"')) {
      // Escape any existing quotes by doubling them
      final escapedField = field.replaceAll('"', '""');
      return '"$escapedField"';
    }
    return field;
  }
}
