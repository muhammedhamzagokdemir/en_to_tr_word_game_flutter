import '../data/word_puzzle_data.dart';
import '../models/question_model.dart';
import '../models/word_model.dart';

enum StudyDifficulty {
  easy,
  medium,
  hard,
  expert,
  nightmare;

  String get label {
    switch (this) {
      case StudyDifficulty.easy:
        return 'Kolay';
      case StudyDifficulty.medium:
        return 'Orta';
      case StudyDifficulty.hard:
        return 'Zor';
      case StudyDifficulty.expert:
        return 'Uzman';
      case StudyDifficulty.nightmare:
        return 'Kabus';
    }
  }
}

class StudyService {
  List<WordModel> buildSessionWords({StudyDifficulty? difficulty}) {
    final usedWordIds = <int>{};
    final sessionWords = <WordModel>[];

    for (final word in puzzleWords) {
      if (difficulty != null && resolveDifficulty(word) != difficulty) {
        continue;
      }

      if (usedWordIds.add(word.id)) {
        sessionWords.add(word);
      }
    }

    return List<WordModel>.unmodifiable(sessionWords);
  }

  StudyDifficulty resolveDifficulty(WordModel word) {
    switch (word.difficulty) {
      case WordDifficulty.easy:
        return StudyDifficulty.easy;
      case WordDifficulty.medium:
        return StudyDifficulty.medium;
      case WordDifficulty.hard:
        return StudyDifficulty.hard;
      case WordDifficulty.expert:
        return StudyDifficulty.expert;
      case WordDifficulty.nightmare:
        return StudyDifficulty.nightmare;
    }
  }
}
