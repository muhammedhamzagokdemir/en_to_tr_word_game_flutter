import 'data/word_data.dart';

class WordItem {
  const WordItem({required this.english, required this.turkish});

  final String english;
  final String turkish;
}

final List<WordItem> basicWords = List<WordItem>.unmodifiable(
  quizWordPool
      .map(
        (entry) => WordItem(english: entry.word, turkish: entry.correctAnswer),
      )
      .toList(),
);
