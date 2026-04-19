import 'package:flutter/material.dart';

import 'models/multiplayer_player.dart';
import 'services/lan_game_client_base.dart';
import 'services/lan_game_server_base.dart';
import 'widgets/app_surfaces.dart';

class MultiplayerResultPage extends StatefulWidget {
  const MultiplayerResultPage({
    super.key,
    required this.players,
    required this.isHost,
    this.server,
    this.client,
  });

  final List<MultiplayerPlayer> players;
  final bool isHost;
  final LanGameServerBase? server;
  final LanGameClientBase? client;

  @override
  State<MultiplayerResultPage> createState() => _MultiplayerResultPageState();
}

class _MultiplayerResultPageState extends State<MultiplayerResultPage> {
  bool _cleanedUp = false;

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _cleanup() async {
    if (_cleanedUp) {
      return;
    }

    _cleanedUp = true;
    if (widget.isHost) {
      await widget.server?.closeRoom();
    } else {
      await widget.client?.disconnect();
    }
  }

  Future<void> _goHome() async {
    await _cleanup();
    if (!mounted) {
      return;
    }

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.players.isEmpty ? null : widget.players.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Çok Oyunculu Sonuç')),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Final Sıralama',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            winner == null
                                ? 'Kazanan bulunamadı.'
                                : 'Kazanan: ${winner.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.players.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RankingTile(
                          rank: entry.key + 1,
                          player: entry.value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _goHome,
                      child: const Text('Ana Sayfaya Dön'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({required this.rank, required this.player});

  final int rank;
  final MultiplayerPlayer player;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF31557D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              player.isHost ? '${player.name} (Oda Sahibi)' : player.name,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AppBadge(
            label: '${player.score} pt',
            backgroundColor: rank == 1
                ? const Color(0xFFE0F6EB)
                : const Color(0xFFEAF1FF),
            foregroundColor: rank == 1
                ? const Color(0xFF18805C)
                : const Color(0xFF31557D),
            icon: rank == 1 ? Icons.emoji_events_rounded : Icons.stars_rounded,
          ),
        ],
      ),
    );
  }
}
