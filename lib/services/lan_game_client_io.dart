import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/multiplayer_message.dart';
import '../models/multiplayer_player.dart';
import '../models/multiplayer_question_state.dart';
import 'lan_game_client_base.dart';
import 'room_code_service.dart';

LanGameClientBase createLanGameClient() => _LanGameClientIo();

class _LanGameClientIo extends LanGameClientBase {
  final RoomCodeService _roomCodeService = RoomCodeService();
  Socket? _socket;
  StreamSubscription<String>? _subscription;
  final List<MultiplayerPlayer> _players = <MultiplayerPlayer>[];
  String _statusMessage = 'Bağlı değil.';
  String _playerId = '';
  String _playerName = '';
  String _roomCode = '';
  String _hostIp = '';
  int _port = 0;
  MultiplayerQuestionState? _currentQuestion;
  final List<int?> _selectedAnswers = <int?>[];
  String? _selectedAnswer;
  String? _revealedCorrectAnswer;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isGameStarted = false;
  bool _isGameOver = false;
  bool _hasSubmittedAnswer = false;
  bool _receivedTerminalError = false;
  String? _errorMessage;

  @override
  bool get isSupported => true;

  @override
  bool get isConnecting => _isConnecting;

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isGameStarted => _isGameStarted;

  @override
  bool get isGameOver => _isGameOver;

  @override
  String get statusMessage => _statusMessage;

  @override
  String? get errorMessage => _errorMessage;

  @override
  String get playerId => _playerId;

  @override
  String get playerName => _playerName;

  @override
  String get roomCode => _roomCode;

  @override
  String get hostIp => _hostIp;

  @override
  int get port => _port;

  @override
  List<MultiplayerPlayer> get players =>
      List<MultiplayerPlayer>.unmodifiable(_players);

  @override
  MultiplayerQuestionState? get currentQuestion => _currentQuestion;

  @override
  List<int?> get selectedAnswers => List<int?>.unmodifiable(_selectedAnswers);

  @override
  String? get selectedAnswer => _selectedAnswer;

  @override
  String? get revealedCorrectAnswer => _revealedCorrectAnswer;

  @override
  bool get hasSubmittedAnswer => _hasSubmittedAnswer;

  @override
  List<MultiplayerPlayer> get finalRanking {
    final ranking = List<MultiplayerPlayer>.from(_players);
    ranking.sort((a, b) => b.score.compareTo(a.score));
    return ranking;
  }

  @override
  Future<void> connect({
    required String hostIp,
    required int port,
    required String playerName,
  }) async {
    if (_isConnecting || _isConnected) {
      return;
    }

    _isConnecting = true;
    _errorMessage = null;
    _roomCode = '';
    _statusMessage = 'Bağlanıyor...';
    notifyListeners();

    try {
      await _connectToHost(hostIp: hostIp, port: port, playerName: playerName);
    } on SocketException catch (_) {
      _statusMessage = 'Bağlantı başarısız.';
      _errorMessage =
          'Sunucuya bağlanılamadı. Her iki cihazın da aynı Wi‑Fi ağında olduğundan emin olun.';
    } on TimeoutException catch (_) {
      _statusMessage = 'Bağlantı zaman aşımına uğradı.';
      _errorMessage =
          'Bağlantı zaman aşımına uğradı. Odanın açık olduğundan ve yerel ağdan erişilebildiğinden emin olun.';
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  @override
  Future<void> connectWithRoomCode({
    required String roomCode,
    required String playerName,
  }) async {
    if (_isConnecting || _isConnected) {
      return;
    }

    final normalizedRoomCode = RoomCodeService.normalizeRoomCode(roomCode);
    if (normalizedRoomCode.isEmpty) {
      _statusMessage = 'Oda kodu gerekli.';
      _errorMessage = 'Katılmadan önce geçerli bir oda kodu girin.';
      notifyListeners();
      return;
    }

    _isConnecting = true;
    _errorMessage = null;
    _statusMessage = '$normalizedRoomCode odası aranıyor...';
    notifyListeners();

    try {
      final room = await _roomCodeService.discoverRoom(normalizedRoomCode);
      if (room == null) {
        _statusMessage = 'Oda bulunamadı.';
        _errorMessage =
            'Bu yerel ağda $normalizedRoomCode koduna sahip etkin bir oda bulunamadı.';
        return;
      }

      _roomCode = room.roomCode;
      _statusMessage = 'Oda bulundu. Bağlanıyor...';
      notifyListeners();
      await _connectToHost(
        hostIp: room.hostAddress,
        port: room.port,
        playerName: playerName,
      );
    } on RoomCodeCollisionException catch (_) {
      _statusMessage = 'Yinelenen oda kodu algılandı.';
      _errorMessage =
          '$normalizedRoomCode koduna birden fazla oda yanıt verdi. Oda sahibinden yeni bir oda kurmasını isteyin.';
    } on SocketException catch (_) {
      _statusMessage = 'Oda araması başarısız.';
      _errorMessage =
          'Bu oda yerel ağda aranamadı. Her iki cihazın da aynı Wi‑Fi ağında olduğundan emin olun.';
    } on TimeoutException catch (_) {
      _statusMessage = 'Oda araması zaman aşımına uğradı.';
      _errorMessage =
          'Oda araması zaman aşımına uğradı. Oda sahibinin aynı Wi‑Fi ağında olduğundan ve odanın açık olduğundan emin olun.';
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _handleRawMessage(String rawMessage) {
    try {
      final message = MultiplayerMessage.fromRaw(rawMessage);
      switch (message.type) {
        case 'joined':
          _errorMessage = null;
          _playerId = message.payload['playerId']?.toString() ?? '';
          _roomCode = RoomCodeService.normalizeRoomCode(
            message.payload['roomCode']?.toString() ?? _roomCode,
          );
          _updatePlayers(message.payload['players']);
          _statusMessage =
              message.payload['status']?.toString() ?? _statusMessage;
          break;
        case 'player_list':
          _updatePlayers(message.payload['players']);
          _statusMessage =
              message.payload['status']?.toString() ?? _statusMessage;
          break;
        case 'start_game':
          _isGameStarted = true;
          _statusMessage = 'Oyun başladı.';
          break;
        case 'question':
          _currentQuestion = MultiplayerQuestionState.fromJson(message.payload);
          _applyQuestionIndex(_currentQuestion!.index);
          _ensureSelectedAnswersLength(_currentQuestion!.total);
          _selectedAnswer = null;
          _revealedCorrectAnswer = null;
          _hasSubmittedAnswer = false;
          _isGameStarted = true;
          _statusMessage = 'Soru ${_currentQuestion!.index + 1} yayında.';
          break;
        case 'question_changed':
        case 'question_state':
          _applyQuestionIndex(_readInt(message.payload['questionIndex']));
          break;
        case 'host_option_selected':
          _applyHostOptionSelection(
            questionIndex: _readInt(message.payload['questionIndex']),
            selectedOptionIndex: _readInt(
              message.payload['selectedOptionIndex'],
            ),
          );
          break;
        case 'host_answer':
          _applyHostOptionSelection(
            questionIndex: _readInt(message.payload['questionIndex']),
            selectedOptionIndex: _readInt(message.payload['selectedIndex']),
          );
          break;
        case 'answer_result':
          _revealedCorrectAnswer = message.payload['correctAnswer']?.toString();
          _statusMessage = _revealedCorrectAnswer == null
              ? 'Cevap gönderildi. Oda sahibi bekleniyor.'
              : 'Cevaplar gösterildi.';
          break;
        case 'score_update':
          _updatePlayers(message.payload['players']);
          break;
        case 'player_left':
          _statusMessage =
              message.payload['message']?.toString() ?? 'Bir oyuncu ayrıldı.';
          break;
        case 'game_over':
          _updatePlayers(message.payload['players']);
          _isGameOver = true;
          _statusMessage = 'Oyun bitti.';
          break;
        case 'error':
          _statusMessage =
              message.payload['message']?.toString() ?? 'Bağlantı hatası.';
          _errorMessage = _statusMessage;
          _receivedTerminalError = true;
          _isConnected = false;
          break;
      }
    } catch (_) {
      _statusMessage = 'Sunucu yanıtı çözümlenemedi.';
      _errorMessage = 'Sunucudan geçersiz bir yanıt alındı.';
    }

    notifyListeners();
  }

  void _applyQuestionIndex(int questionIndex) {
    if (_currentQuestion == null || questionIndex < 0) {
      return;
    }

    if (_currentQuestion!.index == questionIndex) {
      return;
    }

    _currentQuestion = MultiplayerQuestionState(
      id: _currentQuestion!.id,
      word: _currentQuestion!.word,
      questionText: _currentQuestion!.questionText,
      options: _currentQuestion!.options,
      index: questionIndex,
      total: _currentQuestion!.total,
      difficultyLabel: _currentQuestion!.difficultyLabel,
    );
  }

  void _applyHostOptionSelection({
    required int questionIndex,
    required int selectedOptionIndex,
  }) {
    if (questionIndex < 0 || selectedOptionIndex < 0) {
      return;
    }

    _ensureSelectedAnswersLength(_currentQuestion?.total ?? questionIndex + 1);
    if (questionIndex >= _selectedAnswers.length) {
      return;
    }

    _selectedAnswers[questionIndex] = selectedOptionIndex;
    debugPrint('CLIENT received host_option_selected');
    debugPrint('CLIENT applied selected option: $selectedOptionIndex');
  }

  void _updatePlayers(dynamic rawPlayers) {
    if (rawPlayers is! List) {
      return;
    }

    _players
      ..clear()
      ..addAll(
        rawPlayers.whereType<Map<String, dynamic>>().map(
          MultiplayerPlayer.fromJson,
        ),
      );
  }

  void _ensureSelectedAnswersLength(int totalQuestions) {
    if (_selectedAnswers.length >= totalQuestions) {
      return;
    }

    _selectedAnswers.addAll(
      List<int?>.filled(totalQuestions - _selectedAnswers.length, null),
    );
  }

  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? -1;
    }

    return -1;
  }

  @override
  Future<void> submitAnswer(String answer) async {
    if (!_isConnected ||
        _hasSubmittedAnswer ||
        answer.isEmpty ||
        _socket == null) {
      return;
    }

    _selectedAnswer = answer;
    _hasSubmittedAnswer = true;
    _socket!.writeln(
      MultiplayerMessage(type: 'answer', payload: {'answer': answer}).encode(),
    );
    _statusMessage = 'Cevap gönderildi. Oda sahibi bekleniyor.';
    notifyListeners();
  }

  void _handleDisconnected() {
    _isConnected = false;
    if (_receivedTerminalError) {
      notifyListeners();
      return;
    }

    if (!_isGameOver) {
      _statusMessage = 'Oda sahibi bağlantıyı kesti. Oda kapandı.';
      _errorMessage = _statusMessage;
    }
    notifyListeners();
  }

  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _socket?.close();
    } catch (_) {
      // Ignore cleanup errors.
    }
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    _receivedTerminalError = false;
    _errorMessage = null;
    _statusMessage = 'Bağlı değil.';
    _playerId = '';
    _playerName = '';
    _hostIp = '';
    _port = 0;
    _roomCode = '';
    _players.clear();
    _currentQuestion = null;
    _selectedAnswer = null;
    _revealedCorrectAnswer = null;
    _hasSubmittedAnswer = false;
    _isGameStarted = false;
    _isGameOver = false;
    _selectedAnswers.clear();
    notifyListeners();
  }

  Future<void> _connectToHost({
    required String hostIp,
    required int port,
    required String playerName,
  }) async {
    _socket = await Socket.connect(
      hostIp,
      port,
      timeout: const Duration(seconds: 5),
    );
    _hostIp = hostIp;
    _port = port;
    _playerName = playerName;
    _subscription = utf8.decoder
        .bind(_socket!)
        .transform(const LineSplitter())
        .listen(
          _handleRawMessage,
          onDone: _handleDisconnected,
          onError: (_) => _handleDisconnected(),
        );
    _socket!.writeln(
      MultiplayerMessage(type: 'join', payload: {'name': playerName}).encode(),
    );
    _isConnected = true;
    _receivedTerminalError = false;
    _statusMessage = _roomCode.isEmpty
        ? 'Bağlandı. Oda sahibi bekleniyor.'
        : '$_roomCode odasına bağlandı. Oda sahibi bekleniyor.';
  }
}
