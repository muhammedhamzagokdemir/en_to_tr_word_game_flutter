import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({
    super.key,
    required this.todaySolvedQuestions,
    required this.todayPlayTimeInSeconds,
  });

  final int todaySolvedQuestions;
  final int todayPlayTimeInSeconds;

  @override
  Widget build(BuildContext context) {
    const int questionTarget = 10;
    const int playTimeTarget = 300;

    final questionCompleted = todaySolvedQuestions >= questionTarget;
    final playTimeCompleted = todayPlayTimeInSeconds >= playTimeTarget;

    return Scaffold(
      appBar: AppBar(title: const Text('Görevler'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TaskCard(
              title: 'Bugün 10 soru çöz',
              progressText: 'İlerleme: $todaySolvedQuestions / $questionTarget',
              isCompleted: questionCompleted,
            ),
            const SizedBox(height: 12),
            _TaskCard(
              title: 'Bugün 5 dakika oyna',
              progressText:
                  'İlerleme: $todayPlayTimeInSeconds / $playTimeTarget saniye',
              isCompleted: playTimeCompleted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.progressText,
    required this.isCompleted,
  });

  final String title;
  final String progressText;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(progressText),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.hourglass_bottom,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted ? 'Tamamlandı' : 'Devam Ediyor',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
