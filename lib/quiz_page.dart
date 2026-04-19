import 'dart:async';

import 'package:flutter/material.dart';

import 'models/question_model.dart';
import 'result_page.dart';
import 'services/level_service.dart';
import 'services/quiz_service.dart';
import 'widgets/app_surfaces.dart';
import 'widgets/quiz_word_background.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    this.onCorrect,
    this.onWrong,
    this.onPlayTimeUpdate,
  });

  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;
  final ValueChanged<int>? onPlayTimeUpdate;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  final Stopwatch _stopwatch = Stopwatch();
  final LevelService _levelService = LevelService();
  final QuizService _quizService = QuizService();
  final Set<int> _usedQuestionIds = <int>{};
  Timer? _timer;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  List<QuestionModel> _questions = <QuestionModel>[];
  List<String?> _selectedAnswers = <String?>[];
  int _currentQuestionIndex = 0;
  int _lastReportedSeconds = 0;
  int _currentLevel = LevelService.initialLevel;
  int? _selectedIndex;
  bool _isAnswered = false;
  bool _isAdvancing = false;
  bool _isCorrect = false;
  bool _isLoading = true;
  bool _resultsReported = false;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _reportElapsedTime();
    });
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(_shakeController);
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    final savedLevel = await _levelService.getCurrentLevel();
    if (!mounted) {
      return;
    }

    setState(() {
      _currentLevel = savedLevel;
      _prepareSession();
      _isLoading = false;
    });
  }

  void _prepareSession() {
    _usedQuestionIds.clear();
    _questions = _quizService.buildSessionQuestions(
      currentLevel: _currentLevel,
      questionCount: QuizService.questionCountPerSession,
      excludedQuestionIds: _usedQuestionIds,
    );
    _selectedAnswers = List<String?>.filled(_questions.length, null);
    _currentQuestionIndex = 0;
    _selectedIndex = null;
    _isAnswered = false;
    _isAdvancing = false;
    _isCorrect = false;
    _resultsReported = false;
  }

  void _reportElapsedTime() {
    final elapsedSeconds = _stopwatch.elapsed.inSeconds;
    final deltaSeconds = elapsedSeconds - _lastReportedSeconds;

    if (deltaSeconds > 0) {
      _lastReportedSeconds = elapsedSeconds;
      widget.onPlayTimeUpdate?.call(deltaSeconds);
    }
  }

  QuestionModel get _currentQuestion => _questions[_currentQuestionIndex];

  int get _correctCount {
    int total = 0;
    for (int index = 0; index < _questions.length; index++) {
      final selectedAnswer = _selectedAnswers[index];
      if (selectedAnswer != null &&
          _questions[index].isCorrect(selectedAnswer)) {
        total++;
      }
    }
    return total;
  }

  int get _wrongCount =>
      _selectedAnswers.whereType<String>().length - _correctCount;

  void _restoreCurrentQuestionState() {
    final savedAnswer = _selectedAnswers[_currentQuestionIndex];
    final savedIndex = savedAnswer == null
        ? null
        : _currentQuestion.options.indexOf(savedAnswer);

    _selectedIndex = savedIndex != null && savedIndex >= 0 ? savedIndex : null;
    _isAnswered = savedAnswer != null;
    _isCorrect = savedAnswer != null && _currentQuestion.isCorrect(savedAnswer);
    _isAdvancing = false;
  }

  void _reportQuizResults() {
    if (_resultsReported) {
      return;
    }

    for (int index = 0; index < _selectedAnswers.length; index++) {
      final answer = _selectedAnswers[index];
      if (answer == null) {
        continue;
      }

      if (_questions[index].isCorrect(answer)) {
        widget.onCorrect?.call();
      } else {
        widget.onWrong?.call();
      }
    }

    _resultsReported = true;
  }

  Future<void> _selectAnswer(int optionIndex) async {
    if (_isAdvancing || _questions.isEmpty) {
      return;
    }

    final answeredQuestionIndex = _currentQuestionIndex;
    final selectedAnswer = _currentQuestion.options[optionIndex];
    final answerIsCorrect = _currentQuestion.isCorrect(selectedAnswer);

    setState(() {
      _selectedIndex = optionIndex;
      _isAnswered = true;
      _isAdvancing = true;
      _isCorrect = answerIsCorrect;
      _selectedAnswers[_currentQuestionIndex] = selectedAnswer;
      _usedQuestionIds.add(_currentQuestion.id);
    });

    if (!answerIsCorrect) {
      _shakeController.forward(from: 0);
    }

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted || _currentQuestionIndex != answeredQuestionIndex) {
      return;
    }

    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    if (isLastQuestion) {
      await _finishQuiz();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _restoreCurrentQuestionState();
    });
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex <= 0) {
      return;
    }

    setState(() {
      _currentQuestionIndex--;
      _restoreCurrentQuestionState();
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex >= _questions.length - 1) {
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _restoreCurrentQuestionState();
    });
  }

  Future<void> _finishQuiz() async {
    _reportQuizResults();
    final startingLevel = _currentLevel;
    final levelUp = _levelService.checkLevelUp(
      _correctCount,
      _wrongCount,
      startingLevel,
    );
    final updatedLevel = levelUp ? startingLevel + 1 : startingLevel;

    if (levelUp) {
      await _levelService.saveLevel(updatedLevel);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _currentLevel = updatedLevel;
    });

    await _openResultPage(currentLevel: updatedLevel, levelUp: levelUp);
  }

  Future<void> _openResultPage({
    required int currentLevel,
    required bool levelUp,
  }) async {
    final action = await Navigator.push<ResultAction>(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          totalQuestions: _questions.length,
          correctAnswers: _correctCount,
          wrongAnswers: _wrongCount,
          currentLevel: currentLevel,
          levelUp: levelUp,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (action == ResultAction.restart) {
      setState(() {
        _prepareSession();
      });
      return;
    }

    Navigator.pop(context);
  }

  Color _getOptionColor(int index) {
    if (!_isAnswered) {
      return const Color(0xF9FFFFFF);
    }

    if (_currentQuestion.options[index] == _currentQuestion.correctAnswer) {
      return const Color(0xFF1F8A62);
    }

    if (index == _selectedIndex && !_isCorrect) {
      return const Color(0xFFD55353);
    }

    return const Color(0xF9FFFFFF);
  }

  Color _getOptionBorderColor(int index) {
    if (!_isAnswered) {
      return _selectedIndex == index
          ? const Color(0xFF163B43)
          : const Color(0x180F172A);
    }

    if (_currentQuestion.options[index] == _currentQuestion.correctAnswer) {
      return const Color(0xFF1F8A62);
    }

    if (index == _selectedIndex && !_isCorrect) {
      return const Color(0xFFD55353);
    }

    return const Color(0x180F172A);
  }

  Color _getOptionTextColor(int index) {
    if (!_isAnswered) {
      return Colors.black87;
    }

    if (_currentQuestion.options[index] == _currentQuestion.correctAnswer) {
      return Colors.white;
    }

    if (index == _selectedIndex && !_isCorrect) {
      return Colors.white;
    }

    return Colors.black87;
  }

  double _getShakeOffset(int index) {
    final shouldShake = _isAnswered && !_isCorrect && _selectedIndex == index;
    if (!shouldShake) {
      return 0;
    }
    return _shakeAnimation.value;
  }

  Widget _buildDifficultyChip() {
    if (_questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppBadge(
      label: _currentQuestion.difficultyLabel,
      backgroundColor: const Color(0xFFE7F0FF),
      foregroundColor: const Color(0xFF1F3E78),
      icon: Icons.auto_awesome,
    );
  }

  Widget _buildStatPanel({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Expanded(
      child: AppPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: const Color(0xFF64748B)),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int index) {
    final isCorrectOption =
        _currentQuestion.options[index] == _currentQuestion.correctAnswer;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_getShakeOffset(index), 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _isAdvancing ? null : () => _selectAnswer(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: _getOptionColor(index),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getOptionBorderColor(index)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F0F172A),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        _isAnswered &&
                            (isCorrectOption || index == _selectedIndex)
                        ? const Color(0x26FFFFFF)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        color: _getOptionTextColor(index),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  _currentQuestion.options[index],
                  style: TextStyle(
                    color: _getOptionTextColor(index),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(
                  isCorrectOption && _isAnswered
                      ? Icons.check_circle
                      : _selectedIndex == index
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _getOptionTextColor(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _reportElapsedTime();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Soru bulunamadı.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: AppBackground(
        background: QuizWordBackground(
          words: _questions.map((question) => question.word).toList(),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _buildStatPanel(
                        label: 'Seviye',
                        value: '$_currentLevel',
                        icon: Icons.workspace_premium_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildStatPanel(
                        label: 'Ilerleme',
                        value:
                            '${_currentQuestionIndex + 1}/${_questions.length}',
                        icon: Icons.format_list_numbered,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildDifficultyChip(),
                  ),
                  const SizedBox(height: 18),
                  AppPanel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Soru',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _currentQuestion.questionText,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  for (
                    int index = 0;
                    index < _currentQuestion.options.length;
                    index++
                  )
                    _buildOptionTile(index),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentQuestionIndex == 0 || _isAdvancing
                              ? null
                              : _goToPreviousQuestion,
                          child: const Text('Geri'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isAdvancing
                              ? null
                              : _currentQuestionIndex == _questions.length - 1
                              ? (_selectedAnswers[_currentQuestionIndex] == null
                                    ? null
                                    : _finishQuiz)
                              : (_selectedAnswers[_currentQuestionIndex] == null
                                    ? null
                                    : _goToNextQuestion),
                          child: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'Bitir'
                                : 'Ileri',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
