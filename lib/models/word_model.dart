import 'question_model.dart';

class WordModel {
  const WordModel({
    required this.id,
    required this.word,
    required this.difficulty,
    required this.sectionId,
    this.hint,
  });

  final int id;
  final String word;
  final WordDifficulty difficulty;
  final int sectionId;
  final String? hint;

  String get english => word;

  String get turkish => hint ?? '';
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.baseRewardPoints,
  });

  final int id;
  final String title;
  final int baseRewardPoints;
}

class SectionModel {
  const SectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.tasks,
  });

  final int id;
  final String title;
  final String description;
  final WordDifficulty difficulty;
  final List<TaskModel> tasks;
}
