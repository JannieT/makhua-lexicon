class Entry {
  final String id;
  final String headword;
  final String? partOfSpeech;
  final String definition;
  final String? exampleSentence;
  final DateTime createdAt;
  final DateTime updatedAt;

  Entry({required this.id, required this.headword, required this.definition, required this.createdAt, required this.updatedAt, this.exampleSentence, this.partOfSpeech});
}

// partOfSpeech enum
// Substantivo (Noun): Words that name people, places, things, or ideas.
// Verbo (Verb): Words that express actions, states, or occurrences.
// Adjetivo (Adjective): Words that describe or modify nouns.
// Advérbio (Adverb): Words that modify verbs, adjectives, or other adverbs, indicating manner, place, time, etc.
// Pronome (Pronoun): Words that replace nouns or noun phrases.
// Numeral (Numeral): Words that express numbers or order.
// Preposição (Preposition): Words that link nouns, pronouns, or phrases to other words within a sentence.
// Conjunção (Conjunction): Words that connect clauses, sentences, or words.
// Interjeição (Interjection): Words or expressions that convey emotion or reaction, often standing alone.
