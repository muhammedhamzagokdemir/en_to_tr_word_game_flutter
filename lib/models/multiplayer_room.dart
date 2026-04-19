import 'multiplayer_player.dart';

class MultiplayerRoom {
  const MultiplayerRoom({
    required this.roomCode,
    required this.hostAddress,
    required this.port,
    this.hostName = 'Host',
    this.status = '',
    this.players = const <MultiplayerPlayer>[],
  });

  final String roomCode;
  final String hostAddress;
  final int port;
  final String hostName;
  final String status;
  final List<MultiplayerPlayer> players;

  int get playerCount => players.length;

  MultiplayerRoom copyWith({
    String? roomCode,
    String? hostAddress,
    int? port,
    String? hostName,
    String? status,
    List<MultiplayerPlayer>? players,
  }) {
    return MultiplayerRoom(
      roomCode: roomCode ?? this.roomCode,
      hostAddress: hostAddress ?? this.hostAddress,
      port: port ?? this.port,
      hostName: hostName ?? this.hostName,
      status: status ?? this.status,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'hostAddress': hostAddress,
      'port': port,
      'hostName': hostName,
      'status': status,
      'playerCount': playerCount,
      'players': players.map((player) => player.toJson()).toList(),
    };
  }

  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'];
    final players = rawPlayers is List
        ? rawPlayers
              .whereType<Map<String, dynamic>>()
              .map(MultiplayerPlayer.fromJson)
              .toList()
        : const <MultiplayerPlayer>[];

    return MultiplayerRoom(
      roomCode: json['roomCode']?.toString() ?? '',
      hostAddress: json['hostAddress']?.toString() ?? '',
      port: _readInt(json['port']),
      hostName: json['hostName']?.toString() ?? 'Host',
      status: json['status']?.toString() ?? '',
      players: players,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
