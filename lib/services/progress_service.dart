import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_model.dart';

class ProgressService {
  static const String _completedTasksKey = 'completed_puzzle_tasks';
  static const String _unlockedSectionKey = 'unlocked_puzzle_section';

  String taskKey(int sectionId, int taskId) {
    return '$sectionId:$taskId';
  }

  Future<Set<String>> getCompletedTaskKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedTasksKey)?.toSet() ?? <String>{};
  }

  Future<void> completeTask(int sectionId, int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedTasks = await getCompletedTaskKeys();
    completedTasks.add(taskKey(sectionId, taskId));
    await prefs.setStringList(_completedTasksKey, completedTasks.toList());
  }

  bool isTaskCompleted(
    Set<String> completedTaskKeys,
    int sectionId,
    int taskId,
  ) {
    return completedTaskKeys.contains(taskKey(sectionId, taskId));
  }

  int completedTaskCount(SectionModel section, Set<String> completedTaskKeys) {
    return section.tasks
        .where(
          (task) => isTaskCompleted(completedTaskKeys, section.id, task.id),
        )
        .length;
  }

  bool isSectionCompleted(SectionModel section, Set<String> completedTaskKeys) {
    return completedTaskCount(section, completedTaskKeys) ==
        section.tasks.length;
  }

  Future<int> getUnlockedSection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unlockedSectionKey) ?? 1;
  }

  Future<void> unlockSection(int sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUnlockedSection = prefs.getInt(_unlockedSectionKey) ?? 1;
    if (sectionId > currentUnlockedSection) {
      await prefs.setInt(_unlockedSectionKey, sectionId);
    }
  }
}
