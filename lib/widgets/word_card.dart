import 'package:flutter/material.dart';

import '../models/question_model.dart';
import '../models/word_model.dart';
import 'app_surfaces.dart';

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.word});

  final WordModel word;

  Color _chipColor(BuildContext context, WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.easy:
        return Colors.green.shade100;
      case WordDifficulty.medium:
        return Colors.orange.shade100;
      case WordDifficulty.hard:
        return Colors.red.shade100;
      case WordDifficulty.expert:
        return Colors.blueGrey.shade100;
      case WordDifficulty.nightmare:
        return const Color(0xFFE7D7F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: AppBadge(
                label: word.difficulty.label,
                backgroundColor: _chipColor(context, word.difficulty),
                foregroundColor: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              word.english,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              word.turkish.isEmpty ? '-' : word.turkish,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
