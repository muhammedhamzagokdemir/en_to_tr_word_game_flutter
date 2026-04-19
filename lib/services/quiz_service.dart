import 'dart:math';

import '../data/word_data.dart';
import '../models/question_model.dart';

class QuizService {
  static const int questionCountPerSession = 25;

  final Random _random = Random();

  List<QuestionModel> buildSessionQuestions({
    required int currentLevel,
    int questionCount = questionCountPerSession,
    Set<int> excludedQuestionIds = const <int>{},
  }) {
    final availableWords = quizWordPool
        .where((entry) => !excludedQuestionIds.contains(entry.id))
        .toList();

    if (availableWords.isEmpty) {
      return <QuestionModel>[];
    }

    final selectedWords = _selectWordsForLevel(
      currentLevel: currentLevel,
      questionCount: questionCount,
      availableWords: availableWords,
    );

    return selectedWords
        .map(
          (word) => QuestionModel(
            id: word.id,
            word: word.word,
            correctAnswer: word.correctAnswer,
            options: _buildOptions(word, availableWords),
            difficulty: word.difficulty,
          ),
        )
        .toList(growable: false);
  }

  List<WordEntry> _selectWordsForLevel({
    required int currentLevel,
    required int questionCount,
    required List<WordEntry> availableWords,
  }) {
    final selectedWords = <WordEntry>[];
    final usedIds = <int>{};
    final quotas = _quotasForLevel(currentLevel, questionCount);

    for (final quota in quotas) {
      _takeWords(
        selectedWords: selectedWords,
        usedIds: usedIds,
        availableWords: availableWords,
        difficulty: quota.difficulty,
        count: quota.count,
      );
    }

    for (final difficulty in _fallbackOrderForLevel(currentLevel)) {
      if (selectedWords.length >= questionCount) {
        break;
      }

      _takeWords(
        selectedWords: selectedWords,
        usedIds: usedIds,
        availableWords: availableWords,
        difficulty: difficulty,
        count: questionCount - selectedWords.length,
      );
    }

    if (selectedWords.length < questionCount) {
      final remainingWords =
          availableWords.where((entry) => !usedIds.contains(entry.id)).toList()
            ..shuffle(_random);
      selectedWords.addAll(
        remainingWords.take(questionCount - selectedWords.length),
      );
    }

    selectedWords.shuffle(_random);
    return selectedWords.take(questionCount).toList(growable: false);
  }

  void _takeWords({
    required List<WordEntry> selectedWords,
    required Set<int> usedIds,
    required List<WordEntry> availableWords,
    required WordDifficulty difficulty,
    required int count,
  }) {
    if (count <= 0) {
      return;
    }

    final candidates =
        availableWords
            .where(
              (entry) =>
                  entry.difficulty == difficulty && !usedIds.contains(entry.id),
            )
            .toList()
          ..shuffle(_random);

    final wordsToAdd = candidates.take(count);
    for (final word in wordsToAdd) {
      selectedWords.add(word);
      usedIds.add(word.id);
    }
  }

  List<String> _buildOptions(WordEntry currentWord, List<WordEntry> pool) {
    final distractors = <String>[];
    final prioritizedPools = [
      pool
          .where(
            (entry) =>
                entry.id != currentWord.id &&
                entry.difficulty == currentWord.difficulty,
          )
          .toList(),
      pool.where((entry) => entry.id != currentWord.id).toList(),
    ];

    for (final distractorPool in prioritizedPools) {
      distractorPool.shuffle(_random);
      for (final candidate in distractorPool) {
        if (candidate.correctAnswer == currentWord.correctAnswer) {
          continue;
        }
        if (distractors.contains(candidate.correctAnswer)) {
          continue;
        }

        distractors.add(candidate.correctAnswer);
        if (distractors.length == 3) {
          break;
        }
      }

      if (distractors.length == 3) {
        break;
      }
    }

    final options = <String>[currentWord.correctAnswer, ...distractors.take(3)]
      ..shuffle(_random);

    return options;
  }

  List<_DifficultyQuota> _quotasForLevel(int currentLevel, int questionCount) {
    if (currentLevel <= 3) {
      return [
        _DifficultyQuota(difficulty: WordDifficulty.easy, count: questionCount),
      ];
    }

    if (currentLevel <= 6) {
      return [
        _DifficultyQuota(difficulty: WordDifficulty.easy, count: 15),
        _DifficultyQuota(difficulty: WordDifficulty.medium, count: 10),
      ];
    }

    return [
      _DifficultyQuota(difficulty: WordDifficulty.medium, count: 10),
      _DifficultyQuota(difficulty: WordDifficulty.hard, count: 15),
    ];
  }

  List<WordDifficulty> _fallbackOrderForLevel(int currentLevel) {
    if (currentLevel <= 3) {
      return [WordDifficulty.easy, WordDifficulty.medium, WordDifficulty.hard];
    }

    if (currentLevel <= 6) {
      return [WordDifficulty.easy, WordDifficulty.medium, WordDifficulty.hard];
    }

    return [WordDifficulty.hard, WordDifficulty.medium, WordDifficulty.easy];
  }
}

class _DifficultyQuota {
  const _DifficultyQuota({required this.difficulty, required this.count});

  final WordDifficulty difficulty;
  final int count;
}
