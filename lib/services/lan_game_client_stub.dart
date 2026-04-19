import '../models/multiplayer_player.dart';
import '../models/multiplayer_question_state.dart';
import 'lan_game_client_base.dart';

LanGameClientBase createLanGameClient() => _UnsupportedLanGameClient();

class _UnsupportedLanGameClient extends LanGameClientBase {
  @override
  bool get isSupported => false;

  @override
  bool get isConnecting => false;

  @override
  bool get isConnected => false;

  @override
  bool get isGameStarted => false;

  @override
  bool get isGameOver => false;

  @override
  String get statusMessage => 'LAN çok oyunculu bu platformda desteklenmiyor.';

  @override
  String? get errorMessage => 'LAN çok oyunculu bu platformda desteklenmiyor.';

  @override
  String get playerId => '';

  @override
  String get playerName => '';

  @override
  String get roomCode => '';

  @override
  String get hostIp => '';

  @override
  int get port => 0;

  @override
  List<MultiplayerPlayer> get players => const <MultiplayerPlayer>[];

  @override
  MultiplayerQuestionState? get currentQuestion => null;

  @override
  List<int?> get selectedAnswers => const <int?>[];

  @override
  String? get selectedAnswer => null;

  @override
  String? get revealedCorrectAnswer => null;

  @override
  bool get hasSubmittedAnswer => false;

  @override
  List<MultiplayerPlayer> get finalRanking => const <MultiplayerPlayer>[];

  @override
  Future<void> connect({
    required String hostIp,
    required int port,
    required String playerName,
  }) async {}

  @override
  Future<void> connectWithRoomCode({
    required String roomCode,
    required String playerName,
  }) async {}

  @override
  void clearError() {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> submitAnswer(String answer) async {}
}
