import 'package:flutter/material.dart';

import 'models/multiplayer_player.dart';
import 'models/multiplayer_question_state.dart';
import 'multiplayer_result_page.dart';
import 'services/lan_game_client_base.dart';
import 'services/lan_game_server_base.dart';
import 'widgets/app_surfaces.dart';
import 'widgets/quiz_word_background.dart';

class MultiplayerQuizPage extends StatefulWidget {
  const MultiplayerQuizPage.host({super.key, required this.server})
    : client = null;

  const MultiplayerQuizPage.client({super.key, required this.client})
    : server = null;

  final LanGameServerBase? server;
  final LanGameClientBase? client;

  bool get isHost => server != null;

  @override
  State<MultiplayerQuizPage> createState() => _MultiplayerQuizPageState();
}

class _MultiplayerQuizPageState extends State<MultiplayerQuizPage> {
  bool _navigatedToResults = false;

  Listenable get _controller => widget.server ?? widget.client!;

  MultiplayerQuestionState? get _currentQuestion => widget.isHost
      ? widget.server!.currentQuestion
      : widget.client!.currentQuestion;

  List<MultiplayerPlayer> get _players =>
      widget.isHost ? widget.server!.players : widget.client!.players;

  List<int?> get _selectedAnswers => widget.isHost
      ? widget.server!.selectedAnswers
      : widget.client!.selectedAnswers;

  String? get _selectedAnswer => widget.isHost
      ? widget.server!.submittedAnswers[widget.server!.hostPlayerId]
      : widget.client!.selectedAnswer;

  String? get _revealedCorrectAnswer => widget.isHost
      ? widget.server!.revealedCorrectAnswer
      : widget.client!.revealedCorrectAnswer;

  bool get _hasAnswered =>
      _selectedAnswer != null && _selectedAnswer!.isNotEmpty;

  int? get _synchronizedSelectedIndex {
    final question = _currentQuestion;
    if (question == null) {
      return null;
    }

    if (question.index < 0 || question.index >= _selectedAnswers.length) {
      return null;
    }

    return _selectedAnswers[question.index];
  }

  int? _selectedIndexForQuestion(MultiplayerQuestionState question) {
    if (question.index < 0 || question.index >= _selectedAnswers.length) {
      return null;
    }

    return _selectedAnswers[question.index];
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    if (!mounted) {
      return;
    }

    if (!widget.isHost &&
        !widget.client!.isConnected &&
        !widget.client!.isGameOver &&
        !_navigatedToResults) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.client!.statusMessage)));
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    final isGameOver = widget.isHost
        ? widget.server!.isGameOver
        : widget.client!.isGameOver;
    if (isGameOver && !_navigatedToResults) {
      _navigatedToResults = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerResultPage(
            players: widget.isHost
                ? widget.server!.finalRanking
                : widget.client!.finalRanking,
            isHost: widget.isHost,
            server: widget.server,
            client: widget.client,
          ),
        ),
      );
      return;
    }

    setState(() {});
  }

  Future<void> _submitAnswer(String answer) async {
    if (_hasAnswered || _revealedCorrectAnswer != null) {
      return;
    }

    if (widget.isHost) {
      await widget.server!.submitHostAnswer(answer);
    } else {
      await widget.client!.submitAnswer(answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final sortedPlayers = List<MultiplayerPlayer>.from(_players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final synchronizedSelectedIndex = question == null
        ? _synchronizedSelectedIndex
        : _selectedIndexForQuestion(question);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHost ? 'Oda Sahibi Quiz' : 'Çok Oyunculu Quiz'),
      ),
      body: AppBackground(
        background: QuizWordBackground(
          words: question == null ? const <String>[] : <String>[question.word],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPanel(
                  child: Row(
                    children: [
                      Expanded(
                        child: _HeaderMetric(
                          label: 'Soru',
                          value: question == null
                              ? '-'
                              : '${question.index + 1}/${question.total}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HeaderMetric(
                          label: 'Durum',
                          value: _revealedCorrectAnswer == null
                              ? (_hasAnswered ? 'Bekleniyor' : 'Cevaplanıyor')
                              : 'Gösterildi',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBadge(
                        label: question?.difficultyLabel ?? 'Bekleniyor',
                        backgroundColor: const Color(0xFFEAF1FF),
                        foregroundColor: const Color(0xFF31557D),
                        icon: Icons.auto_awesome,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question?.questionText ?? 'Sonraki soru bekleniyor...',
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (question != null)
                        for (
                          var optionIndex = 0;
                          optionIndex < question.options.length;
                          optionIndex++
                        )
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OptionTile(
                              label: question.options[optionIndex],
                              isSelected:
                                  synchronizedSelectedIndex == optionIndex,
                              isCorrect:
                                  _revealedCorrectAnswer ==
                                  question.options[optionIndex],
                              isWrong:
                                  _revealedCorrectAnswer != null &&
                                  synchronizedSelectedIndex == optionIndex &&
                                  _revealedCorrectAnswer !=
                                      question.options[optionIndex],
                              onTap: () =>
                                  _submitAnswer(question.options[optionIndex]),
                              enabled:
                                  !_hasAnswered &&
                                  _revealedCorrectAnswer == null,
                            ),
                          ),
                      if (_revealedCorrectAnswer != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Doğru cevap: $_revealedCorrectAnswer',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF18805C),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ] else if (_hasAnswered) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Cevap gönderildi. Oda sahibi bekleniyor.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Canlı Skor Tablosu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...sortedPlayers.map(
                        (player) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ScoreRow(
                            player: player,
                            isLeader:
                                sortedPlayers.isNotEmpty &&
                                player.id == sortedPlayers.first.id,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isHost) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.server!.canRevealAnswers
                              ? widget.server!.revealAnswers
                              : null,
                          child: const Text('Cevapları Göster'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.server!.canAdvanceQuestion
                              ? widget.server!.nextQuestion
                              : null,
                          child: Text(
                            question != null &&
                                    question.index + 1 == question.total
                                ? 'Oyunu Bitir'
                                : 'Sonraki Soru',
                          ),
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

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1A0F172A)),
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
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xFFF8FAFC);
    Color borderColor = const Color(0x1A0F172A);
    Color textColor = const Color(0xFF0F172A);

    if (isCorrect) {
      backgroundColor = const Color(0xFF1F8A62);
      borderColor = const Color(0xFF1F8A62);
      textColor = Colors.white;
    } else if (isWrong) {
      backgroundColor = const Color(0xFFD55353);
      borderColor = const Color(0xFFD55353);
      textColor = Colors.white;
    } else if (isSelected) {
      borderColor = const Color(0xFF163B43);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.player, required this.isLeader});

  final MultiplayerPlayer player;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A0F172A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              player.isHost ? '${player.name} (Oda Sahibi)' : player.name,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (player.hasAnswered)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.check_circle,
                size: 18,
                color: Color(0xFF18805C),
              ),
            ),
          AppBadge(
            label: '${player.score} pt',
            backgroundColor: isLeader
                ? const Color(0xFFE0F6EB)
                : const Color(0xFFEAF1FF),
            foregroundColor: isLeader
                ? const Color(0xFF18805C)
                : const Color(0xFF31557D),
            icon: isLeader ? Icons.emoji_events_rounded : Icons.stars_rounded,
          ),
        ],
      ),
    );
  }
}
