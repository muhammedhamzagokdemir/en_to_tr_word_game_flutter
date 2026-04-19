enum WordDifficulty {
  easy,
  medium,
  hard,
  expert,
  nightmare;

  String get label {
    switch (this) {
      case WordDifficulty.easy:
        return 'Kolay';
      case WordDifficulty.medium:
        return 'Orta';
      case WordDifficulty.hard:
        return 'Zor';
      case WordDifficulty.expert:
        return 'Uzman';
      case WordDifficulty.nightmare:
        return 'Kabus';
    }
  }
}

class WordEntry {
  const WordEntry({
    required this.id,
    required this.word,
    required this.correctAnswer,
    required this.difficulty,
  });

  final int id;
  final String word;
  final String correctAnswer;
  final WordDifficulty difficulty;
}

class QuestionModel {
  QuestionModel({
    required this.id,
    required this.word,
    required this.correctAnswer,
    required this.options,
    required this.difficulty,
  }) : assert(
         options.length >= 4,
         'QuestionModel requires at least four options.',
       ),
       assert(
         options.contains(correctAnswer),
         'QuestionModel options must contain the correct answer.',
       );

  final int id;
  final String word;
  final String correctAnswer;
  final List<String> options;
  final WordDifficulty difficulty;

  String get questionText => "'$word' kelimesinin Türkçe anlamı nedir?";

  String get difficultyLabel => difficulty.label;

  bool isCorrect(String selectedAnswer) {
    return selectedAnswer == correctAnswer;
  }
}
