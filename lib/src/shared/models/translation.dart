class Translation {
  final String? headwords;
  final String? description;

  Translation({this.headwords, this.description});

  factory Translation.fromJson(Map<String, dynamic>? json) {
    return Translation(headwords: json?['headwords'], description: json?['description']);
  }

  Map<String, dynamic> toJson() {
    return {'headwords': headwords, 'description': description};
  }

  @override
  String toString() {
    return 'Translation(headwords: $headwords, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (other is Translation) {
      return headwords == other.headwords && description == other.description;
    }
    return false;
  }

  @override
  int get hashCode => headwords.hashCode ^ description.hashCode;
}
