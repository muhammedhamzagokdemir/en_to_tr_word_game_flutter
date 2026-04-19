import '../data/word_puzzle_data.dart';
import '../models/question_model.dart';
import '../models/word_model.dart';

class WordFilterService {
  List<WordModel> filterWords({WordDifficulty? difficulty}) {
    if (difficulty == null) {
      return List<WordModel>.unmodifiable(puzzleWords);
    }

    return List<WordModel>.unmodifiable(
      puzzleWords.where((word) => word.difficulty == difficulty),
    );
  }
}
