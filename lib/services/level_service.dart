import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  static const int initialLevel = 1;
  static const int maxLevel = 10;
  static const int requiredCorrectAnswers = 25;
  static const String _levelKey = 'current_level';

  Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? initialLevel;
  }

  bool checkLevelUp(int correctCount, int wrongCount, int currentLevel) {
    if (currentLevel >= maxLevel) {
      return false;
    }

    return correctCount >= requiredCorrectAnswers && wrongCount == 0;
  }

  Future<void> saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, level);
  }
}
