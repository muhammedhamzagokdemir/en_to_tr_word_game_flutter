import 'package:flutter/material.dart';

import 'multiplayer_quiz_page.dart';
import 'services/lan_game_server.dart';
import 'services/lan_game_server_base.dart';
import 'widgets/app_surfaces.dart';

class HostGamePage extends StatefulWidget {
  const HostGamePage({super.key});

  @override
  State<HostGamePage> createState() => _HostGamePageState();
}

class _HostGamePageState extends State<HostGamePage> {
  final LanGameServerBase _server = createLanGameServer();
  bool _handoffToGame = false;

  @override
  void initState() {
    super.initState();
    _server.addListener(_handleServerChange);
    if (_server.isSupported) {
      _server.start();
    }
  }

  @override
  void dispose() {
    _server.removeListener(_handleServerChange);
    if (!_handoffToGame) {
      _server.closeRoom();
    }
    super.dispose();
  }

  void _handleServerChange() {
    if (!mounted) {
      return;
    }

    if (_server.hasStarted &&
        _server.currentQuestion != null &&
        !_handoffToGame) {
      _handoffToGame = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerQuizPage.host(server: _server),
        ),
      );
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oda Kur')),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Oda Bilgileri',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFCADAF7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Oda Kodu',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF31557D),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _server.roomCode.isEmpty
                                  ? 'Oluşturuluyor...'
                                  : _server.roomCode,
                              style: const TextStyle(
                                fontSize: 28,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'Durum', value: _server.statusMessage),
                      _InfoRow(
                        label: 'Oyuncular',
                        value: '${_server.players.length} bağlı',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lobi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_server.isSupported)
                        const Text(
                          'LAN çok oyunculu bu platformda desteklenmiyor.',
                          style: TextStyle(
                            color: Color(0xFFD55353),
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else if (_server.players.isEmpty)
                        const Text(
                          'Henüz bağlı oyuncu yok.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        )
                      else
                        ..._server.players.map(
                          (player) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PlayerTile(
                              name: player.name,
                              score: player.score,
                              subtitle: player.isHost
                                  ? 'Oda sahibi'
                                  : 'Bağlı oyuncu',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _server.canStartGame ? _server.startGame : null,
                  child: const Text('Oyunu Başlat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.name,
    required this.score,
    required this.subtitle,
  });

  final String name;
  final int score;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1A0F172A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AppBadge(
            label: '$score pt',
            backgroundColor: const Color(0xFFE7EEF8),
            foregroundColor: const Color(0xFF31557D),
            icon: Icons.stars_rounded,
          ),
        ],
      ),
    );
  }
}
