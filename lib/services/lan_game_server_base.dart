import 'package:flutter/foundation.dart';

import '../models/multiplayer_player.dart';
import '../models/multiplayer_question_state.dart';

abstract class LanGameServerBase extends ChangeNotifier {
  bool get isSupported;
  bool get isRunning;
  bool get hasStarted;
  bool get isGameOver;
  bool get canStartGame;
  bool get canRevealAnswers;
  bool get canAdvanceQuestion;
  String get roomCode;
  String get localIp;
  int get port;
  String get statusMessage;
  String get hostPlayerId;
  List<MultiplayerPlayer> get players;
  MultiplayerQuestionState? get currentQuestion;
  List<int?> get selectedAnswers;
  String? get revealedCorrectAnswer;
  Map<String, String> get submittedAnswers;
  List<MultiplayerPlayer> get finalRanking;

  Future<void> start({int port = 4040, String hostName = 'Oda Sahibi'});
  Future<void> startGame();
  Future<void> submitHostAnswer(String answer);
  Future<void> revealAnswers();
  Future<void> nextQuestion();
  Future<void> closeRoom();
}
