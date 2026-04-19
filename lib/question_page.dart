import 'dart:async';

import 'package:flutter/material.dart';

import 'word_model.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    super.key,
    required this.onCorrect,
    required this.onWrong,
    this.onTimeUpdate,
  });

  final VoidCallback onCorrect;
  final VoidCallback onWrong;
  final ValueChanged<int>? onTimeUpdate;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  static const int _questionCount = 50;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  late final List<WordItem> _sessionWords;
  int _currentQuestionIndex = 0;
  int _lastReportedSeconds = 0;
  bool _answered = false;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _sessionWords = _createSessionWords();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _reportElapsedTime();
    });
  }

  List<WordItem> _createSessionWords() {
    final words = List<WordItem>.from(basicWords)..shuffle();
    final int count = words.length < _questionCount
        ? words.length
        : _questionCount;
    return words.take(count).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _reportElapsedTime();
    super.dispose();
  }

  void _reportElapsedTime() {
    final int elapsedSeconds = _stopwatch.elapsed.inSeconds;
    final int deltaSeconds = elapsedSeconds - _lastReportedSeconds;

    if (deltaSeconds > 0) {
      _lastReportedSeconds = elapsedSeconds;
      widget.onTimeUpdate?.call(deltaSeconds);
    }
  }

  Future<void> _answerQuestion(bool knewIt) async {
    if (_answered) {
      return;
    }

    setState(() {
      _answered = true;
    });

    if (knewIt) {
      widget.onCorrect();
    } else {
      widget.onWrong();
    }

    _reportElapsedTime();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(knewIt ? 'Bildin' : 'Bilemedin'),
        duration: const Duration(milliseconds: 350),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    if (_currentQuestionIndex >= _sessionWords.length - 1) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _answered = false;
      _showAnswer = false;
    });
  }

  void _revealAnswer() {
    if (_answered || _showAnswer) {
      return;
    }

    setState(() {
      _showAnswer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _sessionWords[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Soru'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_currentQuestionIndex + 1} / ${_sessionWords.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                currentWord.english,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_showAnswer)
                Text(
                  currentWord.turkish,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _answered ? null : () => _answerQuestion(true),
                child: const Text('Bildim'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _answered ? null : () => _answerQuestion(false),
                child: const Text('Bilemedim'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _answered ? null : _revealAnswer,
                child: const Text('Türkçeyi Göster'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
