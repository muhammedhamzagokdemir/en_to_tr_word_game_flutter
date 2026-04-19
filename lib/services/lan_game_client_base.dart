import 'package:flutter/foundation.dart';

import '../models/multiplayer_player.dart';
import '../models/multiplayer_question_state.dart';

abstract class LanGameClientBase extends ChangeNotifier {
  bool get isSupported;
  bool get isConnecting;
  bool get isConnected;
  bool get isGameStarted;
  bool get isGameOver;
  String get statusMessage;
  String? get errorMessage;
  String get playerId;
  String get playerName;
  String get roomCode;
  String get hostIp;
  int get port;
  List<MultiplayerPlayer> get players;
  MultiplayerQuestionState? get currentQuestion;
  List<int?> get selectedAnswers;
  String? get selectedAnswer;
  String? get revealedCorrectAnswer;
  bool get hasSubmittedAnswer;
  List<MultiplayerPlayer> get finalRanking;

  Future<void> connect({
    required String hostIp,
    required int port,
    required String playerName,
  });
  Future<void> connectWithRoomCode({
    required String roomCode,
    required String playerName,
  });
  Future<void> submitAnswer(String answer);
  void clearError();
  Future<void> disconnect();
}
