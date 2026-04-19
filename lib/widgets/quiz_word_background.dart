import 'package:flutter/material.dart';

import '../data/word_puzzle_data.dart';

class QuizWordBackground extends StatelessWidget {
  const QuizWordBackground({super.key, required this.words});

  final List<String> words;

  static const List<_WordSpot> _spots = [
    _WordSpot(leftFactor: 0.05, topFactor: 0.06, rotation: -0.26, size: 30),
    _WordSpot(leftFactor: 0.55, topFactor: 0.08, rotation: 0.16, size: 26),
    _WordSpot(leftFactor: 0.14, topFactor: 0.20, rotation: 0.08, size: 22),
    _WordSpot(leftFactor: 0.62, topFactor: 0.26, rotation: -0.18, size: 34),
    _WordSpot(leftFactor: 0.04, topFactor: 0.38, rotation: 0.18, size: 24),
    _WordSpot(leftFactor: 0.50, topFactor: 0.46, rotation: -0.10, size: 28),
    _WordSpot(leftFactor: 0.18, topFactor: 0.62, rotation: -0.20, size: 32),
    _WordSpot(leftFactor: 0.66, topFactor: 0.66, rotation: 0.12, size: 22),
    _WordSpot(leftFactor: 0.08, topFactor: 0.82, rotation: 0.10, size: 26),
    _WordSpot(leftFactor: 0.56, topFactor: 0.86, rotation: -0.14, size: 30),
  ];

  List<String> get _displayWords {
    final uniqueWords = <String>{};
    for (final word in words) {
      uniqueWords.add(word.toUpperCase());
      if (uniqueWords.length == _spots.length) {
        break;
      }
    }

    if (uniqueWords.length < _spots.length) {
      for (final entry in puzzleWords) {
        uniqueWords.add(entry.english.toUpperCase());
        if (uniqueWords.length == _spots.length) {
          break;
        }
      }
    }

    return uniqueWords.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final displayWords = _displayWords;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (int index = 0; index < displayWords.length; index++)
                Positioned(
                  left: constraints.maxWidth * _spots[index].leftFactor,
                  top: constraints.maxHeight * _spots[index].topFactor,
                  child: Transform.rotate(
                    angle: _spots[index].rotation,
                    child: Text(
                      displayWords[index],
                      style: TextStyle(
                        fontSize: _spots[index].size,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                        color: const Color(0x160F172A),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WordSpot {
  const _WordSpot({
    required this.leftFactor,
    required this.topFactor,
    required this.rotation,
    required this.size,
  });

  final double leftFactor;
  final double topFactor;
  final double rotation;
  final double size;
}
