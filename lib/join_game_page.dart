import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'multiplayer_quiz_page.dart';
import 'services/lan_game_client.dart';
import 'services/lan_game_client_base.dart';
import 'widgets/app_surfaces.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key});

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  final LanGameClientBase _client = createLanGameClient();
  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _playerNameController = TextEditingController();
  bool _handoffToGame = false;
  String? _visibleErrorMessage;

  @override
  void initState() {
    super.initState();
    _client.addListener(_handleClientChange);
  }

  @override
  void dispose() {
    _client.removeListener(_handleClientChange);
    _roomCodeController.dispose();
    _playerNameController.dispose();
    if (!_handoffToGame) {
      _client.disconnect();
    }
    super.dispose();
  }

  void _handleClientChange() {
    if (!mounted) {
      return;
    }

    final errorMessage = _client.errorMessage;
    if (errorMessage != null && errorMessage != _visibleErrorMessage) {
      _visibleErrorMessage = errorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showErrorAlert(errorMessage);
        _client.clearError();
      });
    }

    if (_client.isGameStarted &&
        _client.currentQuestion != null &&
        !_handoffToGame) {
      _handoffToGame = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerQuizPage.client(client: _client),
        ),
      );
      return;
    }

    setState(() {});
  }

  Future<void> _showErrorAlert(String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bağlantı Hatası'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _connect() async {
    final roomCode = _roomCodeController.text.trim().toUpperCase();
    final playerName = _playerNameController.text.trim();

    if (roomCode.isEmpty || playerName.isEmpty) {
      await _showErrorAlert(
        'Katılmadan önce geçerli bir oda kodu ve oyuncu adı girin.',
      );
      return;
    }

    _roomCodeController.value = _roomCodeController.value.copyWith(
      text: roomCode,
      selection: TextSelection.collapsed(offset: roomCode.length),
    );
    _visibleErrorMessage = null;
    await _client.connectWithRoomCode(
      roomCode: roomCode,
      playerName: playerName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Odaya Katıl')),
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
                        'Oda Kodu ile Katıl',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _roomCodeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Oda Kodu',
                          hintText: 'AB12CD',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _playerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Oyuncu Adı',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _client.isConnecting ? null : _connect,
                  child: Text(
                    _client.isConnecting ? 'Bağlanıyor...' : 'Odaya Katıl',
                  ),
                ),
                const SizedBox(height: 16),
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lobi Durumu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _client.statusMessage,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_client.roomCode.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Oda Kodu: ${_client.roomCode}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (_client.players.isEmpty)
                        const Text(
                          'Bağlı oyuncular burada görünecek.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        )
                      else
                        ..._client.players.map(
                          (player) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _JoinPlayerTile(
                              name: player.name,
                              isHost: player.isHost,
                              score: player.score,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinPlayerTile extends StatelessWidget {
  const _JoinPlayerTile({
    required this.name,
    required this.isHost,
    required this.score,
  });

  final String name;
  final bool isHost;
  final int score;

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
            child: Text(
              isHost ? '$name (Oda Sahibi)' : name,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AppBadge(
            label: '$score pt',
            backgroundColor: const Color(0xFFEAF1FF),
            foregroundColor: const Color(0xFF31557D),
          ),
        ],
      ),
    );
  }
}
