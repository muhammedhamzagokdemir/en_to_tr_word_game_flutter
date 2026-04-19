import 'package:flutter/material.dart';

import 'models/word_model.dart';
import 'services/study_service.dart';
import 'widgets/app_surfaces.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final StudyService _studyService = StudyService();

  StudyDifficulty? _selectedDifficulty;
  List<WordModel> _sessionWords = <WordModel>[];
  int _currentIndex = 0;
  bool _isTranslationVisible = false;

  @override
  void initState() {
    super.initState();
    _rebuildSessionWords();
  }

  WordModel? get _currentWord {
    if (_sessionWords.isEmpty) {
      return null;
    }
    if (_currentIndex < 0 || _currentIndex >= _sessionWords.length) {
      return null;
    }
    return _sessionWords[_currentIndex];
  }

  void _rebuildSessionWords() {
    final words = _studyService.buildSessionWords(
      difficulty: _selectedDifficulty,
    );

    setState(() {
      _sessionWords = words;
      _currentIndex = 0;
      _isTranslationVisible = false;
    });
  }

  void _changeDifficulty(StudyDifficulty? difficulty) {
    _selectedDifficulty = difficulty;
    _rebuildSessionWords();
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) {
      return;
    }

    setState(() {
      _currentIndex--;
      _isTranslationVisible = false;
    });
  }

  void _goToNext() {
    if (_currentIndex >= _sessionWords.length - 1) {
      return;
    }

    setState(() {
      _currentIndex++;
      _isTranslationVisible = false;
    });
  }

  void _toggleTranslation() {
    setState(() {
      _isTranslationVisible = !_isTranslationVisible;
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }

  Color _difficultyColor(StudyDifficulty difficulty) {
    switch (difficulty) {
      case StudyDifficulty.easy:
        return Colors.green.shade100;
      case StudyDifficulty.medium:
        return Colors.orange.shade100;
      case StudyDifficulty.hard:
        return Colors.deepOrange.shade100;
      case StudyDifficulty.expert:
        return Colors.blueGrey.shade100;
      case StudyDifficulty.nightmare:
        return const Color(0xFFE7D7F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentWord;
    final currentDifficulty = currentWord == null
        ? null
        : _studyService.resolveDifficulty(currentWord);

    return Scaffold(
      appBar: AppBar(title: const Text('Çalış')),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Çalışma Kartları',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bu oturumdaki kelime sayısı: ${_sessionWords.length}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(
                            label: 'Tümü',
                            selected: _selectedDifficulty == null,
                            onTap: () => _changeDifficulty(null),
                          ),
                          _buildFilterChip(
                            label: 'Kolay',
                            selected:
                                _selectedDifficulty == StudyDifficulty.easy,
                            onTap: () =>
                                _changeDifficulty(StudyDifficulty.easy),
                          ),
                          _buildFilterChip(
                            label: 'Orta',
                            selected:
                                _selectedDifficulty == StudyDifficulty.medium,
                            onTap: () =>
                                _changeDifficulty(StudyDifficulty.medium),
                          ),
                          _buildFilterChip(
                            label: 'Zor',
                            selected:
                                _selectedDifficulty == StudyDifficulty.hard,
                            onTap: () =>
                                _changeDifficulty(StudyDifficulty.hard),
                          ),
                          _buildFilterChip(
                            label: 'Uzman',
                            selected:
                                _selectedDifficulty == StudyDifficulty.expert,
                            onTap: () =>
                                _changeDifficulty(StudyDifficulty.expert),
                          ),
                          _buildFilterChip(
                            label: 'Kabus',
                            selected:
                                _selectedDifficulty ==
                                StudyDifficulty.nightmare,
                            onTap: () =>
                                _changeDifficulty(StudyDifficulty.nightmare),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (currentWord == null)
                  const AppPanel(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Bu seviyede kelime bulunamadı.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  Align(
                    alignment: Alignment.center,
                    child: AppBadge(
                      label: '${_currentIndex + 1} / ${_sessionWords.length}',
                      backgroundColor: const Color(0xFFE7EEF8),
                      foregroundColor: const Color(0xFF31557D),
                      icon: Icons.menu_book_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppPanel(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: AppBadge(
                            label: currentDifficulty!.label,
                            backgroundColor: _difficultyColor(
                              currentDifficulty,
                            ),
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentWord.english,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _isTranslationVisible
                              ? Text(
                                  currentWord.turkish.isEmpty
                                      ? '-'
                                      : currentWord.turkish,
                                  key: ValueKey<int>(currentWord.id),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF334155),
                                  ),
                                )
                              : const Text(
                                  'Türkçeyi görmek için butona bas.',
                                  key: ValueKey<String>('translation-hidden'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _toggleTranslation,
                          child: Text(
                            _isTranslationVisible
                                ? 'Türkçeyi Gizle'
                                : 'Türkçeyi Göster',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentIndex == 0 ? null : _goToPrevious,
                          child: const Text('Geri'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentIndex >= _sessionWords.length - 1
                              ? null
                              : _goToNext,
                          child: const Text('İleri'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
