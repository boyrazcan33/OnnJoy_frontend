class Entry {
  final int id;
  final String language;
  final String text;
  final DateTime createdAt;

  const Entry({
    required this.id,
    required this.language,
    required this.text,
    required this.createdAt,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'],
      language: json['language'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class EntryRequest {
  final String text;
  final String language;

  const EntryRequest({
    required this.text,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'language': language,
    };
  }
}
