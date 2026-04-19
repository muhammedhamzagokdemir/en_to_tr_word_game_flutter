import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/multiplayer_message.dart';
import '../models/multiplayer_player.dart';
import '../models/multiplayer_question_state.dart';
import '../models/multiplayer_room.dart';
import '../models/question_model.dart';
import 'lan_game_server_base.dart';
import 'level_service.dart';
import 'quiz_service.dart';
import 'room_code_service.dart';

LanGameServerBase createLanGameServer() => _LanGameServerIo();

class _LanGameServerIo extends LanGameServerBase {
  final QuizService _quizService = QuizService();
  final LevelService _levelService = LevelService();
  final RoomCodeService _roomCodeService = RoomCodeService();
  final Random _random = Random();
  final List<MultiplayerPlayer> _players = <MultiplayerPlayer>[];
  final Map<String, Socket> _clientSockets = <String, Socket>{};
  final Map<String, StreamSubscription<String>> _socketSubscriptions =
      <String, StreamSubscription<String>>{};
  final Map<String, String> _submittedAnswers = <String, String>{};
  final List<QuestionModel> _questions = <QuestionModel>[];
  final List<int?> _selectedAnswers = <int?>[];

  ServerSocket? _serverSocket;
  String _roomCode = '';
  String _localIp = '';
  int _port = 0;
  String _statusMessage = 'Oda henüz başlatılmadı.';
  String _hostPlayerId = '';
  int _currentQuestionIndex = -1;
  String? _revealedCorrectAnswer;
  bool _isQuestionRevealed = false;
  bool _isRunning = false;
  bool _hasStarted = false;
  bool _isGameOver = false;

  @override
  bool get isSupported => true;

  @override
  bool get isRunning => _isRunning;

  @override
  bool get hasStarted => _hasStarted;

  @override
  bool get isGameOver => _isGameOver;

  @override
  bool get canStartGame => !_hasStarted && _players.length >= 2;

  @override
  bool get canRevealAnswers =>
      _hasStarted &&
      !_isGameOver &&
      currentQuestion != null &&
      !_isQuestionRevealed;

  @override
  bool get canAdvanceQuestion =>
      _hasStarted &&
      !_isGameOver &&
      currentQuestion != null &&
      _isQuestionRevealed;

  @override
  String get roomCode => _roomCode;

  @override
  String get localIp => _localIp;

  @override
  int get port => _port;

  @override
  String get statusMessage => _statusMessage;

  @override
  String get hostPlayerId => _hostPlayerId;

  @override
  List<MultiplayerPlayer> get players =>
      List<MultiplayerPlayer>.unmodifiable(_players);

  @override
  MultiplayerQuestionState? get currentQuestion {
    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= _questions.length) {
      return null;
    }

    final question = _questions[_currentQuestionIndex];
    return MultiplayerQuestionState(
      id: question.id,
      word: question.word,
      questionText: question.questionText,
      options: question.options,
      index: _currentQuestionIndex,
      total: _questions.length,
      difficultyLabel: question.difficultyLabel,
    );
  }

  @override
  List<int?> get selectedAnswers => List<int?>.unmodifiable(_selectedAnswers);

  @override
  String? get revealedCorrectAnswer => _revealedCorrectAnswer;

  @override
  Map<String, String> get submittedAnswers =>
      Map<String, String>.unmodifiable(_submittedAnswers);

  @override
  List<MultiplayerPlayer> get finalRanking {
    final ranking = List<MultiplayerPlayer>.from(_players);
    ranking.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return ranking;
  }

  @override
  Future<void> start({int port = 4040, String hostName = 'Oda Sahibi'}) async {
    if (_isRunning) {
      return;
    }

    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _port = _serverSocket!.port;
      _localIp = await _resolveLocalIp();
      _roomCode = await _roomCodeService.createAvailableRoomCode();
      _hostPlayerId = _buildPlayerId();
      _players
        ..clear()
        ..add(
          MultiplayerPlayer(id: _hostPlayerId, name: hostName, isHost: true),
        );
      _statusMessage = '$_roomCode odası açık. Oyuncular bekleniyor.';
      await _roomCodeService.hostRoom(_buildRoomMetadata(hostName: hostName));
      _isRunning = true;
      _hasStarted = false;
      _isGameOver = false;
      _serverSocket!.listen(_handleSocketConnection);
    } catch (_) {
      await _roomCodeService.close();
      await _serverSocket?.close();
      _serverSocket = null;
      _roomCode = '';
      _port = 0;
      _localIp = '';
      _players.clear();
      _statusMessage = 'LAN odası başlatılamadı.';
    }

    notifyListeners();
  }

  void _handleSocketConnection(Socket socket) {
    final subscription = utf8.decoder
        .bind(socket)
        .transform(const LineSplitter())
        .listen(
          (rawMessage) => _handleClientMessage(socket, rawMessage),
          onDone: () => _handleSocketClosed(socket),
          onError: (_) => _handleSocketClosed(socket),
        );

    _socketSubscriptions[socket.remotePort.toString()] = subscription;
  }

  Future<void> _handleClientMessage(Socket socket, String rawMessage) async {
    try {
      final message = MultiplayerMessage.fromRaw(rawMessage);
      switch (message.type) {
        case 'join':
          await _handleJoin(socket, message.payload);
          break;
        case 'answer':
          _handleAnswer(socket, message.payload);
          break;
        default:
          _sendMessage(
            socket,
            const MultiplayerMessage(
              type: 'error',
              payload: {'message': 'Bilinmeyen mesaj türü.'},
            ),
          );
      }
    } catch (_) {
      _sendMessage(
        socket,
        const MultiplayerMessage(
          type: 'error',
          payload: {'message': 'Geçersiz mesaj verisi.'},
        ),
      );
    }
  }

  Future<void> _handleJoin(Socket socket, Map<String, dynamic> payload) async {
    if (_hasStarted) {
      _sendMessage(
        socket,
        const MultiplayerMessage(
          type: 'error',
          payload: {'message': 'Oyun zaten başladı.'},
        ),
      );
      await socket.close();
      return;
    }

    final requestedName = payload['name']?.toString().trim() ?? '';
    if (requestedName.isEmpty) {
      _sendMessage(
        socket,
        const MultiplayerMessage(
          type: 'error',
          payload: {'message': 'Oyuncu adı gerekli.'},
        ),
      );
      await socket.close();
      return;
    }

    final nameExists = _players.any(
      (player) => player.name.toLowerCase() == requestedName.toLowerCase(),
    );
    if (nameExists) {
      _sendMessage(
        socket,
        const MultiplayerMessage(
          type: 'error',
          payload: {'message': 'Bu oyuncu adı zaten kullanılıyor.'},
        ),
      );
      await socket.close();
      return;
    }

    final playerId = _buildPlayerId();
    _clientSockets[playerId] = socket;

    _players.add(MultiplayerPlayer(id: playerId, name: requestedName));
    _statusMessage =
        'Oyuncu $_roomCode odasına katıldı. ${_players.length} oyuncu bağlı.';
    _refreshRoomMetadata();
    notifyListeners();

    _sendMessage(
      socket,
      MultiplayerMessage(
        type: 'joined',
        payload: {
          'playerId': playerId,
          'roomCode': _roomCode,
          'hostIp': _localIp,
          'port': _port,
          'players': _players.map((player) => player.toJson()).toList(),
          'status': _statusMessage,
        },
      ),
    );
    _broadcastPlayerList();
  }

  void _handleAnswer(Socket socket, Map<String, dynamic> payload) {
    final playerId = _findPlayerIdBySocket(socket);
    if (playerId == null || !_hasStarted || _isQuestionRevealed) {
      return;
    }

    final answer = payload['answer']?.toString() ?? '';
    if (answer.isEmpty || _submittedAnswers.containsKey(playerId)) {
      return;
    }

    _submittedAnswers[playerId] = answer;
    _updatePlayer(playerId, (player) => player.copyWith(hasAnswered: true));
    _sendMessage(
      socket,
      const MultiplayerMessage(
        type: 'answer_result',
        payload: {'accepted': true},
      ),
    );
    _broadcastPlayerList();
  }

  @override
  Future<void> submitHostAnswer(String answer) async {
    if (!_hasStarted || _isQuestionRevealed || answer.isEmpty) {
      return;
    }

    if (_submittedAnswers.containsKey(_hostPlayerId)) {
      return;
    }

    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= _questions.length) {
      return;
    }

    final selectedIndex = _questions[_currentQuestionIndex].options.indexOf(
      answer,
    );
    if (selectedIndex == -1) {
      return;
    }

    _submittedAnswers[_hostPlayerId] = answer;
    _updatePlayer(
      _hostPlayerId,
      (player) => player.copyWith(hasAnswered: true),
    );
    _ensureSelectedAnswersLength(_questions.length);
    _selectedAnswers[_currentQuestionIndex] = selectedIndex;
    debugPrint(
      'HOST selected option: $selectedIndex for question $_currentQuestionIndex',
    );
    _broadcastHostOptionSelected(
      questionIndex: _currentQuestionIndex,
      selectedOptionIndex: selectedIndex,
    );
    _broadcastPlayerList();
  }

  @override
  Future<void> startGame() async {
    if (!canStartGame) {
      return;
    }

    final currentLevel = await _levelService.getCurrentLevel();
    _questions
      ..clear()
      ..addAll(
        _quizService.buildSessionQuestions(
          currentLevel: currentLevel,
          questionCount: 10,
        ),
      );

    if (_questions.isEmpty) {
      _statusMessage = 'Çok oyunculu için soru bulunamadı.';
      notifyListeners();
      return;
    }

    _hasStarted = true;
    _isGameOver = false;
    _currentQuestionIndex = 0;
    _selectedAnswers
      ..clear()
      ..addAll(List<int?>.filled(_questions.length, null));
    _prepareQuestion();
    _statusMessage = 'Oyun başladı.';
    _refreshRoomMetadata();
    _broadcast(
      const MultiplayerMessage(
        type: 'start_game',
        payload: {'message': 'Oda sahibi oyunu başlattı.'},
      ),
    );
    _broadcastCurrentQuestion();
    notifyListeners();
  }

  @override
  Future<void> revealAnswers() async {
    if (!canRevealAnswers) {
      return;
    }

    final question = _questions[_currentQuestionIndex];
    _revealedCorrectAnswer = question.correctAnswer;
    _isQuestionRevealed = true;

    for (final player in List<MultiplayerPlayer>.from(_players)) {
      final submittedAnswer = _submittedAnswers[player.id];
      final isCorrect =
          submittedAnswer != null && question.isCorrect(submittedAnswer);
      if (isCorrect) {
        _updatePlayer(
          player.id,
          (value) => value.copyWith(score: value.score + 1),
        );
      }
    }

    _statusMessage = 'Cevaplar gösterildi.';
    _refreshRoomMetadata();
    _broadcast(
      MultiplayerMessage(
        type: 'answer_result',
        payload: {
          'correctAnswer': question.correctAnswer,
          'submittedAnswers': _submittedAnswers,
        },
      ),
    );
    _broadcastScoreUpdate();
    notifyListeners();
  }

  @override
  Future<void> nextQuestion() async {
    if (!canAdvanceQuestion) {
      return;
    }

    final nextIndex = _currentQuestionIndex + 1;
    if (nextIndex >= _questions.length) {
      _isGameOver = true;
      _statusMessage = 'Oyun bitti.';
      _refreshRoomMetadata();
      _broadcast(
        MultiplayerMessage(
          type: 'game_over',
          payload: {
            'players': finalRanking.map((player) => player.toJson()).toList(),
          },
        ),
      );
      notifyListeners();
      return;
    }

    _currentQuestionIndex = nextIndex;
    _prepareQuestion();
    _statusMessage = 'Soru ${_currentQuestionIndex + 1} yayında.';
    _refreshRoomMetadata();
    _broadcastCurrentQuestion();
    notifyListeners();
  }

  void _prepareQuestion() {
    _submittedAnswers.clear();
    _revealedCorrectAnswer = null;
    _isQuestionRevealed = false;
    for (final player in List<MultiplayerPlayer>.from(_players)) {
      _updatePlayer(player.id, (value) => value.copyWith(hasAnswered: false));
    }
  }

  void _broadcastCurrentQuestion() {
    final question = currentQuestion;
    if (question == null) {
      return;
    }

    _broadcast(
      MultiplayerMessage(
        type: 'question_changed',
        payload: {'questionIndex': _currentQuestionIndex},
      ),
    );
    _broadcast(
      MultiplayerMessage(type: 'question', payload: question.toJson()),
    );
  }

  void _broadcastPlayerList() {
    _broadcast(
      MultiplayerMessage(
        type: 'player_list',
        payload: {
          'players': _players.map((player) => player.toJson()).toList(),
          'status': _statusMessage,
        },
      ),
    );
  }

  void _broadcastScoreUpdate() {
    _broadcast(
      MultiplayerMessage(
        type: 'score_update',
        payload: {
          'players': _players.map((player) => player.toJson()).toList(),
        },
      ),
    );
  }

  void _broadcastHostOptionSelected({
    required int questionIndex,
    required int selectedOptionIndex,
  }) {
    _broadcast(
      MultiplayerMessage(
        type: 'host_option_selected',
        payload: {
          'questionIndex': questionIndex,
          'selectedOptionIndex': selectedOptionIndex,
        },
      ),
    );
    debugPrint('HOST broadcast host_option_selected');
  }

  void _broadcast(MultiplayerMessage message) {
    for (final socket in _clientSockets.values) {
      _sendMessage(socket, message);
    }
  }

  void _sendMessage(Socket socket, MultiplayerMessage message) {
    socket.writeln(message.encode());
  }

  void _handleSocketClosed(Socket socket) {
    final playerId = _findPlayerIdBySocket(socket);
    if (playerId == null) {
      return;
    }

    final player = _players.where((value) => value.id == playerId).firstOrNull;
    _clientSockets.remove(playerId);
    _submittedAnswers.remove(playerId);
    _socketSubscriptions.remove(socket.remotePort.toString())?.cancel();
    _players.removeWhere((value) => value.id == playerId);
    _statusMessage = '${player?.name ?? 'Bir oyuncu'} bağlantıyı kesti.';
    _refreshRoomMetadata();
    _broadcast(
      MultiplayerMessage(
        type: 'player_left',
        payload: {'playerId': playerId, 'message': _statusMessage},
      ),
    );
    _broadcastPlayerList();
    notifyListeners();
  }

  String? _findPlayerIdBySocket(Socket socket) {
    for (final entry in _clientSockets.entries) {
      if (entry.value == socket) {
        return entry.key;
      }
    }
    return null;
  }

  void _updatePlayer(
    String playerId,
    MultiplayerPlayer Function(MultiplayerPlayer player) transform,
  ) {
    final index = _players.indexWhere((player) => player.id == playerId);
    if (index == -1) {
      return;
    }

    _players[index] = transform(_players[index]);
  }

  void _ensureSelectedAnswersLength(int totalQuestions) {
    if (_selectedAnswers.length >= totalQuestions) {
      return;
    }

    _selectedAnswers.addAll(
      List<int?>.filled(totalQuestions - _selectedAnswers.length, null),
    );
  }

  @override
  Future<void> closeRoom() async {
    await _roomCodeService.close();

    for (final subscription in _socketSubscriptions.values) {
      await subscription.cancel();
    }
    _socketSubscriptions.clear();

    for (final socket in _clientSockets.values) {
      try {
        socket.writeln(
          const MultiplayerMessage(
            type: 'error',
            payload: {'message': 'Oda sahibi bağlantıyı kesti. Oda kapandı.'},
          ).encode(),
        );
        await socket.flush();
        await socket.close();
      } catch (_) {
        // Ignore cleanup errors.
      }
    }
    _clientSockets.clear();

    await _serverSocket?.close();
    _serverSocket = null;
    _roomCode = '';
    _localIp = '';
    _port = 0;
    _statusMessage = 'Oda henüz başlatılmadı.';
    _hostPlayerId = '';
    _currentQuestionIndex = -1;
    _revealedCorrectAnswer = null;
    _isQuestionRevealed = false;
    _isRunning = false;
    _hasStarted = false;
    _isGameOver = false;
    _questions.clear();
    _submittedAnswers.clear();
    _selectedAnswers.clear();
    _players.clear();
    notifyListeners();
  }

  String _buildPlayerId() {
    final value = DateTime.now().microsecondsSinceEpoch + _random.nextInt(9999);
    return value.toString();
  }

  Future<String> _resolveLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (_isLanAddress(address.address)) {
          return address.address;
        }
      }
    }

    for (final interface in interfaces) {
      if (interface.addresses.isNotEmpty) {
        return interface.addresses.first.address;
      }
    }

    return 'Kullanılamıyor';
  }

  bool _isLanAddress(String address) {
    if (address.startsWith('192.168.') || address.startsWith('10.')) {
      return true;
    }

    if (!address.startsWith('172.')) {
      return false;
    }

    final segments = address.split('.');
    if (segments.length < 2) {
      return false;
    }

    final secondSegment = int.tryParse(segments[1]);
    return secondSegment != null && secondSegment >= 16 && secondSegment <= 31;
  }

  MultiplayerRoom _buildRoomMetadata({String hostName = 'Oda Sahibi'}) {
    final hostPlayer = _players.where((player) => player.isHost).firstOrNull;
    return MultiplayerRoom(
      roomCode: _roomCode,
      hostAddress: _localIp,
      port: _port,
      hostName: hostPlayer?.name ?? hostName,
      status: _statusMessage,
      players: List<MultiplayerPlayer>.unmodifiable(_players),
    );
  }

  void _refreshRoomMetadata() {
    if (_roomCode.isEmpty || _localIp.isEmpty || _port <= 0) {
      return;
    }

    _roomCodeService.updateHostedRoom(_buildRoomMetadata());
  }
}
