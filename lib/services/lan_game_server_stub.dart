import '../models/multiplayer_player.dart';
import '../models/multiplayer_question_state.dart';
import 'lan_game_server_base.dart';

LanGameServerBase createLanGameServer() => _UnsupportedLanGameServer();

class _UnsupportedLanGameServer extends LanGameServerBase {
  @override
  bool get isSupported => false;

  @override
  bool get isRunning => false;

  @override
  bool get hasStarted => false;

  @override
  bool get isGameOver => false;

  @override
  bool get canStartGame => false;

  @override
  bool get canRevealAnswers => false;

  @override
  bool get canAdvanceQuestion => false;

  @override
  String get roomCode => '';

  @override
  String get localIp => '';

  @override
  int get port => 0;

  @override
  String get statusMessage => 'LAN çok oyunculu bu platformda desteklenmiyor.';

  @override
  String get hostPlayerId => '';

  @override
  List<MultiplayerPlayer> get players => const <MultiplayerPlayer>[];

  @override
  MultiplayerQuestionState? get currentQuestion => null;

  @override
  List<int?> get selectedAnswers => const <int?>[];

  @override
  String? get revealedCorrectAnswer => null;

  @override
  Map<String, String> get submittedAnswers => const <String, String>{};

  @override
  List<MultiplayerPlayer> get finalRanking => const <MultiplayerPlayer>[];

  @override
  Future<void> closeRoom() async {}

  @override
  Future<void> nextQuestion() async {}

  @override
  Future<void> revealAnswers() async {}

  @override
  Future<void> start({int port = 4040, String hostName = 'Oda Sahibi'}) async {}

  @override
  Future<void> startGame() async {}

  @override
  Future<void> submitHostAnswer(String answer) async {}
}
