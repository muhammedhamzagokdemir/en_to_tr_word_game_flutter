import 'dart:convert';

class MultiplayerMessage {
  const MultiplayerMessage({
    required this.type,
    this.payload = const <String, dynamic>{},
  });

  final String type;
  final Map<String, dynamic> payload;

  String encode() {
    return jsonEncode({'type': type, 'payload': payload});
  }

  factory MultiplayerMessage.fromRaw(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid message format.');
    }

    final payload = decoded['payload'];
    return MultiplayerMessage(
      type: decoded['type']?.toString() ?? '',
      payload: payload is Map<String, dynamic>
          ? payload
          : const <String, dynamic>{},
    );
  }
}
