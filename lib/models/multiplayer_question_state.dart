class MultiplayerQuestionState {
  const MultiplayerQuestionState({
    required this.id,
    required this.word,
    required this.questionText,
    required this.options,
    required this.index,
    required this.total,
    required this.difficultyLabel,
  });

  final int id;
  final String word;
  final String questionText;
  final List<String> options;
  final int index;
  final int total;
  final String difficultyLabel;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'questionText': questionText,
      'options': options,
      'index': index,
      'total': total,
      'difficultyLabel': difficultyLabel,
    };
  }

  factory MultiplayerQuestionState.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return MultiplayerQuestionState(
      id: _readInt(json['id']),
      word: json['word']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      options: rawOptions is List
          ? rawOptions.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
      index: _readInt(json['index']),
      total: _readInt(json['total']),
      difficultyLabel: json['difficultyLabel']?.toString() ?? '',
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
