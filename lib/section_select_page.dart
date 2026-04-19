import 'package:flutter/material.dart';

import 'data/word_puzzle_data.dart';
import 'services/points_service.dart';
import 'services/progress_service.dart';
import 'widgets/app_surfaces.dart';
import 'word_puzzle_page.dart';

class SectionSelectPage extends StatefulWidget {
  const SectionSelectPage({super.key});

  @override
  State<SectionSelectPage> createState() => _SectionSelectPageState();
}

class _SectionSelectPageState extends State<SectionSelectPage> {
  final ProgressService _progressService = ProgressService();
  final PointsService _pointsService = PointsService();

  bool _isLoading = true;
  int _points = 0;
  int _unlockedSection = 1;
  Set<String> _completedTaskKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final points = await _pointsService.getPoints();
    final unlockedSection = await _progressService.getUnlockedSection();
    final completedTaskKeys = await _progressService.getCompletedTaskKeys();

    if (!mounted) {
      return;
    }

    setState(() {
      _points = points;
      _unlockedSection = unlockedSection;
      _completedTaskKeys = completedTaskKeys;
      _isLoading = false;
    });
  }

  Future<void> _openSection(int sectionId) async {
    final section = puzzleSections.firstWhere((item) => item.id == sectionId);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordPuzzlePage(section: section)),
    );
    await _loadState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kelime Bulmacası')),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPanel(
                backgroundColor: const Color(0xFF173B43),
                borderColor: const Color(0xFF173B43),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bulmaca Puanı',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFD7E4E8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bölümünü seç',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    AppBadge(
                      label: '$_points',
                      backgroundColor: Color(0x26FFFFFF),
                      foregroundColor: Colors.white,
                      icon: Icons.stars_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: puzzleSections.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final section = puzzleSections[index];
                    final isUnlocked = section.id <= _unlockedSection;
                    final completedTasks = _progressService.completedTaskCount(
                      section,
                      _completedTaskKeys,
                    );
                    final isCompleted =
                        completedTasks == section.tasks.length &&
                        section.tasks.isNotEmpty;
                    final progress = section.tasks.isEmpty
                        ? 0.0
                        : completedTasks / section.tasks.length;

                    return AppPanel(
                      padding: EdgeInsets.zero,
                      backgroundColor: isUnlocked
                          ? const Color(0xF9FFFFFF)
                          : const Color(0xEEF5F7FA),
                      child: InkWell(
                        onTap: isUnlocked
                            ? () => _openSection(section.id)
                            : null,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFFE0F6EB)
                                      : isUnlocked
                                      ? const Color(0xFFE4EDF9)
                                      : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_rounded
                                      : isUnlocked
                                      ? Icons.auto_awesome_outlined
                                      : Icons.lock_outline,
                                  color: isCompleted
                                      ? const Color(0xFF18805C)
                                      : isUnlocked
                                      ? const Color(0xFF31557D)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            section.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        AppBadge(
                                          label: isCompleted
                                              ? 'Tamamlandi'
                                              : isUnlocked
                                              ? 'Acik'
                                              : 'Kilitli',
                                          backgroundColor: isCompleted
                                              ? const Color(0xFFE0F6EB)
                                              : isUnlocked
                                              ? const Color(0xFFE7EEF8)
                                              : const Color(0xFFE5E7EB),
                                          foregroundColor: isCompleted
                                              ? const Color(0xFF18805C)
                                              : isUnlocked
                                              ? const Color(0xFF31557D)
                                              : const Color(0xFF6B7280),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      section.description,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        minHeight: 8,
                                        value: progress,
                                        backgroundColor: const Color(
                                          0xFFE2E8F0,
                                        ),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF3A7C75),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Görevler: $completedTasks / ${section.tasks.length}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
