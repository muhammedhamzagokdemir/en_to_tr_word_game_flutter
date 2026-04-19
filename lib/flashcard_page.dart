import 'package:flutter/material.dart';

import 'word_model.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int _currentWordIndex = 0;
  bool _showAnswer = false;

  void _showMeaning() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _goToNextWord() {
    setState(() {
      if (_currentWordIndex < basicWords.length - 1) {
        _currentWordIndex++;
      }
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final WordItem currentWord = basicWords[_currentWordIndex];
    final int totalWords = basicWords.length;
    final double progress = (_currentWordIndex + 1) / totalWords;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelime Çalış')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kelime ${_currentWordIndex + 1} / $totalWords',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentWord.english,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_showAnswer)
                                Text(
                                  currentWord.turkish,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 22),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _showAnswer ? null : _showMeaning,
                        child: const Text('Türkçeyi Göster'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _goToNextWord,
                            child: const Text('Bildim'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _goToNextWord,
                            child: const Text('Bilemedim'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
