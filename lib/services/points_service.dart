import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const String _pointsKey = 'puzzle_points';

  Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  Future<int> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt(_pointsKey) ?? 0;
    final updatedPoints = currentPoints + points;
    await prefs.setInt(_pointsKey, updatedPoints);
    return updatedPoints;
  }

  Future<bool> spendPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt(_pointsKey) ?? 0;
    if (currentPoints < points) {
      return false;
    }

    await prefs.setInt(_pointsKey, currentPoints - points);
    return true;
  }
}
