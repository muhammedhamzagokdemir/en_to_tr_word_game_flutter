import 'dart:math';

import '../data/word_puzzle_data.dart';
import '../models/question_model.dart';
import '../models/word_model.dart';

class WordSelectionService {
  final Random _random = Random();

  List<WordModel> buildSessionWords({
    required int currentLevel,
    required SectionModel section,
    required int taskCount,
    Set<int> excludedWordIds = const <int>{},
  }) {
    final selectedWords = <WordModel>[];
    final usedIds = <int>{...excludedWordIds};
    final sectionWords = puzzleWords
        .where(
          (word) => word.sectionId == section.id && !usedIds.contains(word.id),
        )
        .toList();

    final targetTier = _targetTier(
      currentLevel: currentLevel,
      sectionDifficulty: section.difficulty,
    );

    for (final quota in _quotasForTier(targetTier, taskCount)) {
      _takeWords(
        target: selectedWords,
        usedIds: usedIds,
        candidates: sectionWords,
        difficulty: quota.difficulty,
        count: quota.count,
      );
    }

    for (final difficulty in _fallbackOrder(targetTier)) {
      if (selectedWords.length >= taskCount) {
        break;
      }

      _takeWords(
        target: selectedWords,
        usedIds: usedIds,
        candidates: sectionWords,
        difficulty: difficulty,
        count: taskCount - selectedWords.length,
      );
    }

    if (selectedWords.length < taskCount) {
      final globalCandidates = puzzleWords
          .where((word) => !usedIds.contains(word.id))
          .toList();

      for (final difficulty in _fallbackOrder(targetTier)) {
        if (selectedWords.length >= taskCount) {
          break;
        }

        _takeWords(
          target: selectedWords,
          usedIds: usedIds,
          candidates: globalCandidates,
          difficulty: difficulty,
          count: taskCount - selectedWords.length,
        );
      }
    }

    selectedWords.shuffle(_random);
    return selectedWords.take(taskCount).toList(growable: false);
  }

  int rewardFor({required TaskModel task, required WordModel word}) {
    return task.baseRewardPoints + _difficultyBonus(word.difficulty);
  }

  void _takeWords({
    required List<WordModel> target,
    required Set<int> usedIds,
    required List<WordModel> candidates,
    required WordDifficulty difficulty,
    required int count,
  }) {
    if (count <= 0) {
      return;
    }

    final matches =
        candidates
            .where(
              (word) =>
                  word.difficulty == difficulty && !usedIds.contains(word.id),
            )
            .toList()
          ..shuffle(_random);

    for (final word in matches.take(count)) {
      target.add(word);
      usedIds.add(word.id);
    }
  }

  int _targetTier({
    required int currentLevel,
    required WordDifficulty sectionDifficulty,
  }) {
    final levelTier = _tierForLevel(currentLevel);
    final sectionTier = _tierForDifficulty(sectionDifficulty);
    return max(levelTier, sectionTier);
  }

  int _tierForLevel(int level) {
    if (level <= 3) {
      return 0;
    }
    if (level <= 6) {
      return 1;
    }
    if (level <= 10) {
      return 2;
    }
    return 3;
  }

  int _tierForDifficulty(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.easy:
        return 0;
      case WordDifficulty.medium:
        return 1;
      case WordDifficulty.hard:
        return 2;
      case WordDifficulty.expert:
        return 3;
      case WordDifficulty.nightmare:
        return 4;
    }
  }

  List<_DifficultyQuota> _quotasForTier(int tier, int taskCount) {
    if (tier == 0) {
      return [
        _DifficultyQuota(difficulty: WordDifficulty.easy, count: taskCount),
      ];
    }

    final primaryCount = ((taskCount * 0.6).ceil()).clamp(1, taskCount);
    final secondaryCount = taskCount - primaryCount;

    if (tier == 1) {
      return [
        _DifficultyQuota(difficulty: WordDifficulty.easy, count: primaryCount),
        _DifficultyQuota(
          difficulty: WordDifficulty.medium,
          count: secondaryCount,
        ),
      ];
    }

    if (tier == 2) {
      return [
        _DifficultyQuota(
          difficulty: WordDifficulty.medium,
          count: primaryCount,
        ),
        _DifficultyQuota(
          difficulty: WordDifficulty.hard,
          count: secondaryCount,
        ),
      ];
    }

    if (tier == 3) {
      return [
        _DifficultyQuota(difficulty: WordDifficulty.hard, count: primaryCount),
        _DifficultyQuota(
          difficulty: WordDifficulty.expert,
          count: secondaryCount,
        ),
      ];
    }

    return [
      _DifficultyQuota(difficulty: WordDifficulty.expert, count: primaryCount),
      _DifficultyQuota(
        difficulty: WordDifficulty.nightmare,
        count: secondaryCount,
      ),
    ];
  }

  List<WordDifficulty> _fallbackOrder(int tier) {
    switch (tier) {
      case 0:
      case 1:
        return const [
          WordDifficulty.easy,
          WordDifficulty.medium,
          WordDifficulty.hard,
          WordDifficulty.expert,
          WordDifficulty.nightmare,
        ];
      case 2:
        return const [
          WordDifficulty.medium,
          WordDifficulty.hard,
          WordDifficulty.easy,
          WordDifficulty.expert,
          WordDifficulty.nightmare,
        ];
      case 3:
        return const [
          WordDifficulty.hard,
          WordDifficulty.expert,
          WordDifficulty.nightmare,
          WordDifficulty.medium,
          WordDifficulty.easy,
        ];
      default:
        return const [
          WordDifficulty.expert,
          WordDifficulty.nightmare,
          WordDifficulty.hard,
          WordDifficulty.medium,
          WordDifficulty.easy,
        ];
    }
  }

  int _difficultyBonus(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.easy:
        return 0;
      case WordDifficulty.medium:
        return 4;
      case WordDifficulty.hard:
        return 8;
      case WordDifficulty.expert:
        return 12;
      case WordDifficulty.nightmare:
        return 16;
    }
  }
}

class _DifficultyQuota {
  const _DifficultyQuota({required this.difficulty, required this.count});

  final WordDifficulty difficulty;
  final int count;
}
