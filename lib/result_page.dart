import 'package:flutter/material.dart';

import 'services/level_service.dart';
import 'widgets/app_surfaces.dart';

enum ResultAction { restart, home }

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.currentLevel,
    required this.levelUp,
  });

  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int currentLevel;
  final bool levelUp;

  String get _levelMessage {
    if (levelUp) {
      return 'Tebrikler! Seviye atladın.';
    }

    return '${LevelService.requiredCorrectAnswers} doğru ve 0 yanlış ile seviye atlayabilirsin.';
  }

  String get _levelStatusText {
    return levelUp ? 'Evet' : 'Hayır';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Sonucu')),
      body: AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: AppBadge(
                      label: levelUp ? 'Seviye Atlandı' : 'Quiz Bitti',
                      backgroundColor: levelUp
                          ? const Color(0xFFE0F6EB)
                          : const Color(0xFFE7EEF8),
                      foregroundColor: levelUp
                          ? const Color(0xFF18805C)
                          : const Color(0xFF31557D),
                      icon: levelUp
                          ? Icons.emoji_events_rounded
                          : Icons.flag_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Sonuç Ekranı',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppPanel(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _MetricBox(label: 'Seviye', value: '$currentLevel'),
                            const SizedBox(width: 12),
                            _MetricBox(
                              label: 'Toplam',
                              value: '$totalQuestions',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MetricBox(
                              label: 'Doğru',
                              value: '$correctAnswers',
                              accentColor: const Color(0xFF18805C),
                            ),
                            const SizedBox(width: 12),
                            _MetricBox(
                              label: 'Yanlış',
                              value: '$wrongAnswers',
                              accentColor: const Color(0xFFD55353),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        AppBadge(
                          label: 'Seviye Atlandı mı: $_levelStatusText',
                          backgroundColor: levelUp
                              ? const Color(0xFFE0F6EB)
                              : const Color(0xFFFDF1D9),
                          foregroundColor: levelUp
                              ? const Color(0xFF18805C)
                              : const Color(0xFF9A6700),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _levelMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, ResultAction.restart);
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, ResultAction.home);
                    },
                    child: const Text('Ana Sayfaya Dön'),
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

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    this.accentColor = const Color(0xFF163B43),
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x160F172A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
