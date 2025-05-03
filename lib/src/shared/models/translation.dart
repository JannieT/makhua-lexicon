class Translation {
  final String language;
  final String translatedWord;

  Translation({required this.language, required this.translatedWord});
  Translation.portuguese({required this.translatedWord}) : language = 'pt';
  Translation.english({required this.translatedWord}) : language = 'en';
}
