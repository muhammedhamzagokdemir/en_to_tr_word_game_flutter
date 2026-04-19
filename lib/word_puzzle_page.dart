import 'dart:math';

import 'package:flutter/material.dart';

import 'data/word_puzzle_data.dart';
import 'models/word_model.dart';
import 'services/level_service.dart';
import 'services/points_service.dart';
import 'services/progress_service.dart';
import 'services/theme_service.dart';
import 'services/word_selection_service.dart';
import 'widgets/app_surfaces.dart';

class WordPuzzlePage extends StatefulWidget {
  const WordPuzzlePage({
    super.key,
    required this.section,
    this.replayMode = false,
  });

  final SectionModel section;
  final bool replayMode;

  @override
  State<WordPuzzlePage> createState() => _WordPuzzlePageState();
}

class _WordPuzzlePageState extends State<WordPuzzlePage> {
  static const int revealLetterCost = 5;

  final LevelService _levelService = LevelService();
  final ProgressService _progressService = ProgressService();
  final PointsService _pointsService = PointsService();
  final WordSelectionService _wordSelectionService = WordSelectionService();
  final TextEditingController _answerController = TextEditingController();
  final Random _random = Random();

  bool _isLoading = true;
  int _points = 0;
  int _currentLevel = LevelService.initialLevel;
  int _currentTaskIndex = 0;
  Set<String> _completedTaskKeys = <String>{};
  Set<int> _usedWordIds = <int>{};
  Map<int, WordModel> _taskWords = <int, WordModel>{};
  final Map<int, Set<int>> _revealedPositionsByTaskId = <int, Set<int>>{};
  final Set<int> _replayedSolvedTaskIds = <int>{};
  String? _message;
  Color? _messageColor;

  @override
  void initState() {
    super.initState();
    _loadState();
    ThemeService.instance.isDarkModeNotifier.addListener(_handleThemeChange);
  }

  @override
  void dispose() {
    ThemeService.instance.isDarkModeNotifier.removeListener(_handleThemeChange);
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final points = await _pointsService.getPoints();
    final completedTaskKeys = await _progressService.getCompletedTaskKeys();
    final currentLevel = await _levelService.getCurrentLevel();
    final taskIndex = widget.replayMode
        ? 0
        : (_findNextUnfinishedTaskIndex(completedTaskKeys) ?? 0);
    final taskWords = _buildTaskWords(currentLevel: currentLevel);

    if (!mounted) {
      return;
    }

    setState(() {
      _points = points;
      _currentLevel = currentLevel;
      _completedTaskKeys = completedTaskKeys;
      _currentTaskIndex = taskIndex;
      _taskWords = taskWords;
      _usedWordIds = taskWords.values.map((word) => word.id).toSet();
      _revealedPositionsByTaskId
        ..clear()
        ..addEntries(taskWords.keys.map((taskId) => MapEntry(taskId, <int>{})));
      _replayedSolvedTaskIds.clear();
      _message = null;
      _messageColor = null;
      _isLoading = false;
    });
  }

  void _handleThemeChange() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  bool get _isDarkMode => ThemeService.instance.isDarkMode;

  Color get _pageBackgroundColor => _isDarkMode ? Colors.black : Colors.white;

  Color get _primaryTextColor =>
      _isDarkMode ? Colors.white : const Color(0xFF0F172A);

  Color get _secondaryTextColor =>
      _isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF64748B);

  Color get _panelBackgroundColor =>
      _isDarkMode ? const Color(0xFF111827) : Colors.white;

  Color get _panelBorderColor =>
      _isDarkMode ? const Color(0xFF374151) : const Color(0x1A0F172A);

  Color get _inputFillColor =>
      _isDarkMode ? const Color(0xFF1F2937) : Colors.white;

  Color get _inputTextColor =>
      _isDarkMode ? Colors.white : const Color(0xFF0F172A);

  Map<int, WordModel> _buildTaskWords({required int currentLevel}) {
    final words = _wordSelectionService.buildSessionWords(
      currentLevel: currentLevel,
      section: widget.section,
      taskCount: widget.section.tasks.length,
      excludedWordIds: _usedWordIds,
    );

    final taskWords = <int, WordModel>{};
    for (int index = 0; index < widget.section.tasks.length; index++) {
      if (index >= words.length) {
        break;
      }
      taskWords[widget.section.tasks[index].id] = words[index];
    }
    return taskWords;
  }

  int? _findNextUnfinishedTaskIndex(Set<String> completedTaskKeys) {
    for (int index = 0; index < widget.section.tasks.length; index++) {
      final task = widget.section.tasks[index];
      if (!_progressService.isTaskCompleted(
        completedTaskKeys,
        widget.section.id,
        task.id,
      )) {
        return index;
      }
    }
    return null;
  }

  TaskModel get _currentTask => widget.section.tasks[_currentTaskIndex];

  WordModel? get _currentWord => _taskWords[_currentTask.id];

  bool get _isCurrentTaskPersistedCompleted => _progressService.isTaskCompleted(
      _completedTaskKeys,
      widget.section.id,
      _currentTask.id,
    );

  bool get _isCurrentTaskCompleted {
    if (widget.replayMode) {
      return _replayedSolvedTaskIds.contains(_currentTask.id);
    }

    return _isCurrentTaskPersistedCompleted;
  }

  int get _completedTaskCount {
    if (widget.replayMode) {
      return _replayedSolvedTaskIds.length;
    }

    return _progressService.completedTaskCount(
      widget.section,
      _completedTaskKeys,
    );
  }

  bool get _isSectionCompleted {
    if (widget.replayMode) {
      return _replayedSolvedTaskIds.length >= widget.section.tasks.length;
    }

    return _progressService.isSectionCompleted(
      widget.section,
      _completedTaskKeys,
    );
  }

  Set<int> get _revealedPositions {
    return _revealedPositionsByTaskId.putIfAbsent(
      _currentTask.id,
      () => <int>{},
    );
  }

  List<String> _maskedCharacters() {
    final currentWord = _currentWord;
    if (currentWord == null) {
      return const <String>[];
    }

    final answer = currentWord.word.toUpperCase();
    final characters = <String>[];
    for (int index = 0; index < answer.length; index++) {
      final character = answer[index];
      if (character == ' ') {
        characters.add(' ');
      } else if (_isCurrentTaskCompleted ||
          _revealedPositions.contains(index)) {
        characters.add(character);
      } else {
        characters.add('_');
      }
    }
    return characters;
  }

  Widget _buildWordTiles() {
    final characters = _maskedCharacters();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final character in characters)
          character == ' '
              ? const SizedBox(width: 12, height: 52)
              : Container(
                  width: 46,
                  height: 52,
                  decoration: BoxDecoration(
                    color: character == '_'
                        ? (_isDarkMode
                              ? const Color(0xFF1F2937)
                              : const Color(0xFFF8FAFC))
                        : (_isDarkMode
                              ? const Color(0xFF14332E)
                              : const Color(0xFFE8F6F2)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: character == '_'
                          ? (_isDarkMode
                                ? const Color(0xFF374151)
                                : const Color(0x220F172A))
                          : const Color(0x403A7C75),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      character,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: character == '_'
                            ? (_isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF94A3B8))
                            : (_isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF163B43)),
                      ),
                    ),
                  ),
                ),
      ],
    );
  }

  Future<void> _checkAnswer() async {
    final currentWord = _currentWord;
    if (_isCurrentTaskCompleted || currentWord == null) {
      return;
    }

    final answer = _answerController.text.trim().toLowerCase();
    final isCorrect = answer == currentWord.word.toLowerCase();

    if (!isCorrect) {
      setState(() {
        _message = 'Yanlış cevap, tekrar dene.';
        _messageColor = Colors.red;
      });
      return;
    }

    if (widget.replayMode) {
      setState(() {
        _replayedSolvedTaskIds.add(_currentTask.id);
        _message = 'Bölüm tekrar çözüldü.';
        _messageColor = Colors.green;
      });
      return;
    }

    await _progressService.completeTask(widget.section.id, _currentTask.id);
    final reward = _wordSelectionService.rewardFor(
      task: _currentTask,
      word: currentWord,
    );
    final updatedPoints = await _pointsService.addPoints(reward);
    final completedTaskKeys = await _progressService.getCompletedTaskKeys();

    if (_progressService.isSectionCompleted(
      widget.section,
      completedTaskKeys,
    )) {
      await _progressService.unlockSection(widget.section.id + 1);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _points = updatedPoints;
      _completedTaskKeys = completedTaskKeys;
      _message = 'Görev tamamlandı. +$reward puan';
      _messageColor = Colors.green;
    });
  }

  Future<void> _revealLetter() async {
    final currentWord = _currentWord;
    if (_isCurrentTaskCompleted || currentWord == null) {
      return;
    }

    final hiddenPositions = <int>[];
    final answer = currentWord.word;
    for (int index = 0; index < answer.length; index++) {
      if (answer[index] != ' ' && !_revealedPositions.contains(index)) {
        hiddenPositions.add(index);
      }
    }

    if (hiddenPositions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm harfler zaten gösterildi.')),
      );
      return;
    }

    final hasEnoughPoints = await _pointsService.spendPoints(revealLetterCost);
    if (!hasEnoughPoints) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir harf göstermek için yeterli puan yok.'),
        ),
      );
      return;
    }

    final updatedPoints = await _pointsService.getPoints();
    final revealIndex =
        hiddenPositions[_random.nextInt(hiddenPositions.length)];

    if (!mounted) {
      return;
    }

    setState(() {
      _points = updatedPoints;
      _revealedPositionsByTaskId[_currentTask.id] = {
        ..._revealedPositions,
        revealIndex,
      };
      _message = '$revealLetterCost puan karşılığında bir harf gösterildi.';
      _messageColor = Colors.orange;
    });
  }

  void _nextTask() {
    if (widget.replayMode) {
      final nextTaskIndex = _currentTaskIndex + 1;
      if (nextTaskIndex >= widget.section.tasks.length) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bölüm tamamlandı.')));
        return;
      }

      setState(() {
        _loadTask(nextTaskIndex);
      });
      return;
    }

    int? nextTaskIndex;
    for (
      int index = _currentTaskIndex + 1;
      index < widget.section.tasks.length;
      index++
    ) {
      final task = widget.section.tasks[index];
      if (!_progressService.isTaskCompleted(
        _completedTaskKeys,
        widget.section.id,
        task.id,
      )) {
        nextTaskIndex = index;
        break;
      }
    }

    nextTaskIndex ??= _findNextUnfinishedTaskIndex(_completedTaskKeys);

    if (nextTaskIndex == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bölüm tamamlandı.')));
      return;
    }

    setState(() {
      _loadTask(nextTaskIndex!);
    });
  }

  void _loadTask(int taskIndex) {
    _currentTaskIndex = taskIndex;
    _answerController.clear();
    _message = null;
    _messageColor = null;
  }

  Future<void> _openPreviousSectionReplay() async {
    if (widget.section.id <= 1) {
      return;
    }

    final previousSectionId = widget.section.id - 1;
    final previousSection = puzzleSections.firstWhere(
      (section) => section.id == previousSectionId,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WordPuzzlePage(section: previousSection, replayMode: true),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _pageBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _currentWord;

    return Scaffold(
      backgroundColor: _pageBackgroundColor,
      appBar: AppBar(
        title: Text(widget.section.title),
        backgroundColor: _pageBackgroundColor,
        foregroundColor: _primaryTextColor,
      ),
      body: Container(
        color: _pageBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPanel(
                backgroundColor: const Color(0xFF173B43),
                borderColor: const Color(0xFF173B43),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kelime Bulmacası',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD7E4E8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.section.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _isDarkMode
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppBadge(
                          label: '$_points Puan',
                          backgroundColor: const Color(0x26FFFFFF),
                          foregroundColor: Colors.white,
                          icon: Icons.stars_rounded,
                        ),
                        const SizedBox(height: 8),
                        AppBadge(
                          label: 'Seviye $_currentLevel',
                          backgroundColor: const Color(0x1AFFFFFF),
                          foregroundColor: const Color(0xFFE7F7F1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppPanel(
                backgroundColor: _panelBackgroundColor,
                borderColor: _panelBorderColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.section.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: _secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppBadge(
                            label:
                                'Görevler $_completedTaskCount/${widget.section.tasks.length}',
                            backgroundColor: const Color(0xFFE7EEF8),
                            foregroundColor: const Color(0xFF31557D),
                            icon: Icons.checklist_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (currentWord != null)
                          AppBadge(
                            label: currentWord.difficulty.label,
                            backgroundColor: const Color(0xFFE0F6EB),
                            foregroundColor: const Color(0xFF18805C),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (currentWord != null) ...[
                      Text(
                        'Ipucu',
                        style: TextStyle(
                          fontSize: 13,
                          color: _secondaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentWord.hint ?? '-',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _primaryTextColor,
                        ),
                      ),
                    ] else
                      Text(
                        'Bölüm tamamlandı.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _primaryTextColor,
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildWordTiles(),
                    const SizedBox(height: 16),
                    Text(
                      currentWord == null
                          ? 'Tüm görevler tamamlandı'
                          : 'Ödül: ${_wordSelectionService.rewardFor(task: _currentTask, word: currentWord)} puan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppPanel(
                backgroundColor: _panelBackgroundColor,
                borderColor: _panelBorderColor,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final task in widget.section.tasks)
                      AppBadge(
                        label: 'Görev ${task.id}',
                        icon:
                            _progressService.isTaskCompleted(
                              _completedTaskKeys,
                              widget.section.id,
                              task.id,
                            )
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        backgroundColor:
                            _progressService.isTaskCompleted(
                              _completedTaskKeys,
                              widget.section.id,
                              task.id,
                            )
                            ? const Color(0xFFE0F6EB)
                            : const Color(0xFFF1F5F9),
                        foregroundColor:
                            _progressService.isTaskCompleted(
                              _completedTaskKeys,
                              widget.section.id,
                              task.id,
                            )
                            ? const Color(0xFF18805C)
                            : const Color(0xFF475569),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _answerController,
                enabled: !_isCurrentTaskCompleted && currentWord != null,
                style: TextStyle(color: _inputTextColor),
                decoration: InputDecoration(
                  labelText: 'Gizli kelimeyi yaz',
                  labelStyle: TextStyle(color: _secondaryTextColor),
                  filled: true,
                  fillColor: _inputFillColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCurrentTaskCompleted || currentWord == null
                          ? null
                          : _checkAnswer,
                      child: const Text('Cevabı Kontrol Et'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isCurrentTaskCompleted || currentWord == null
                          ? null
                          : _revealLetter,
                      child: const Text('Harf Göster'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.section.id <= 1
                          ? null
                          : _openPreviousSectionReplay,
                      child: const Text('Önceki Bölüm'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSectionCompleted ? null : _nextTask,
                      child: const Text('Sonraki Görev'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_message != null)
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _messageColor ?? _primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (_isSectionCompleted) ...[
                const SizedBox(height: 20),
                AppPanel(
                  backgroundColor: _isDarkMode
                      ? const Color(0xFF14332E)
                      : const Color(0xFFE0F6EB),
                  borderColor: _isDarkMode
                      ? const Color(0xFF1F6B5E)
                      : const Color(0x3322A06B),
                  child: Text(
                    widget.replayMode
                        ? 'Bölüm tekrar tamamlandı.'
                        : 'Bölüm tamamlandı. Sonraki bölümün kilidi açıldı.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _isDarkMode
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
