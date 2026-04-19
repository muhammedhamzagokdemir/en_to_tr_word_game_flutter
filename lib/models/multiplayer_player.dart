class MultiplayerPlayer {
  const MultiplayerPlayer({
    required this.id,
    required this.name,
    this.score = 0,
    this.isHost = false,
    this.isConnected = true,
    this.hasAnswered = false,
  });

  final String id;
  final String name;
  final int score;
  final bool isHost;
  final bool isConnected;
  final bool hasAnswered;

  MultiplayerPlayer copyWith({
    String? id,
    String? name,
    int? score,
    bool? isHost,
    bool? isConnected,
    bool? hasAnswered,
  }) {
    return MultiplayerPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      isHost: isHost ?? this.isHost,
      isConnected: isConnected ?? this.isConnected,
      hasAnswered: hasAnswered ?? this.hasAnswered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'isHost': isHost,
      'isConnected': isConnected,
      'hasAnswered': hasAnswered,
    };
  }

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      score: _readInt(json['score']),
      isHost: json['isHost'] == true,
      isConnected: json['isConnected'] != false,
      hasAnswered: json['hasAnswered'] == true,
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
