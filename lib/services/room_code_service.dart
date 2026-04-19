import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../models/multiplayer_message.dart';
import '../models/multiplayer_room.dart';

class RoomCodeCollisionException implements Exception {
  const RoomCodeCollisionException(this.roomCode);

  final String roomCode;

  @override
  String toString() {
    return 'Multiple rooms responded for code $roomCode.';
  }
}

class RoomCodeService {
  static const int discoveryPort = 4041;
  static const String _globalBroadcast = '255.255.255.255';
  static const String _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  RoomCodeService({Random? random}) : _random = random ?? Random();

  final Random _random;
  RawDatagramSocket? _hostSocket;
  StreamSubscription<RawSocketEvent>? _hostSubscription;
  MultiplayerRoom? _hostedRoom;

  static String normalizeRoomCode(String input) {
    return input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  Future<String> createAvailableRoomCode({
    Duration timeout = const Duration(milliseconds: 400),
    int maxAttempts = 8,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final code = _generateRoomCode();
      try {
        final existingRoom = await discoverRoom(code, timeout: timeout);
        if (existingRoom == null) {
          return code;
        }
      } on RoomCodeCollisionException {
        // A collision means the code is already effectively taken on the LAN.
      }
    }

    throw const SocketException('Could not reserve a unique room code.');
  }

  Future<void> hostRoom(MultiplayerRoom room) async {
    await close();

    _hostedRoom = room;
    _hostSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
    );
    _hostSocket!.broadcastEnabled = true;
    _hostSubscription = _hostSocket!.listen(_handleHostSocketEvent);
  }

  void updateHostedRoom(MultiplayerRoom room) {
    _hostedRoom = room;
  }

  Future<MultiplayerRoom?> discoverRoom(
    String roomCode, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final normalizedRoomCode = normalizeRoomCode(roomCode);
    if (normalizedRoomCode.isEmpty) {
      return null;
    }

    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
    );
    socket.broadcastEnabled = true;

    final rooms = <String, MultiplayerRoom>{};
    final completer = Completer<List<MultiplayerRoom>>();
    late final StreamSubscription<RawSocketEvent> subscription;
    final timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(rooms.values.toList());
      }
    });

    subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) {
        return;
      }

      final datagram = socket.receive();
      if (datagram == null) {
        return;
      }

      try {
        final message = MultiplayerMessage.fromRaw(
          utf8.decode(datagram.data, allowMalformed: true),
        );
        if (message.type != 'room_found') {
          return;
        }

        final room = MultiplayerRoom.fromJson(message.payload);
        if (normalizeRoomCode(room.roomCode) != normalizedRoomCode) {
          return;
        }

        rooms['${room.hostAddress}:${room.port}'] = room;
      } catch (_) {
        // Ignore unrelated UDP packets on the discovery port.
      }
    });

    final request = MultiplayerMessage(
      type: 'find_room',
      payload: {'roomCode': normalizedRoomCode},
    ).encode();
    final requestBytes = utf8.encode(request);
    final broadcastAddresses = await _buildBroadcastAddresses();
    for (final address in broadcastAddresses) {
      socket.send(requestBytes, address, discoveryPort);
    }

    final discoveredRooms = await completer.future;
    timeoutTimer.cancel();
    await subscription.cancel();
    socket.close();

    if (discoveredRooms.length > 1) {
      throw RoomCodeCollisionException(normalizedRoomCode);
    }

    return discoveredRooms.isEmpty ? null : discoveredRooms.first;
  }

  Future<void> close() async {
    await _hostSubscription?.cancel();
    _hostSubscription = null;
    _hostSocket?.close();
    _hostSocket = null;
    _hostedRoom = null;
  }

  void _handleHostSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read || _hostSocket == null) {
      return;
    }

    final datagram = _hostSocket!.receive();
    if (datagram == null || _hostedRoom == null) {
      return;
    }

    try {
      final message = MultiplayerMessage.fromRaw(
        utf8.decode(datagram.data, allowMalformed: true),
      );
      if (message.type != 'find_room') {
        return;
      }

      final requestedCode = normalizeRoomCode(
        message.payload['roomCode']?.toString() ?? '',
      );
      if (requestedCode != _hostedRoom!.roomCode) {
        return;
      }

      final response = MultiplayerMessage(
        type: 'room_found',
        payload: _hostedRoom!.toJson(),
      ).encode();
      _hostSocket!.send(utf8.encode(response), datagram.address, datagram.port);
    } catch (_) {
      // Ignore malformed discovery requests.
    }
  }

  String _generateRoomCode() {
    final length = 4 + _random.nextInt(3);
    final buffer = StringBuffer();
    for (var index = 0; index < length; index++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  Future<List<InternetAddress>> _buildBroadcastAddresses() async {
    final addresses = <String>{_globalBroadcast};
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final broadcastAddress = _tryBuild24BitBroadcast(address.address);
        if (broadcastAddress != null) {
          addresses.add(broadcastAddress);
        }
      }
    }

    return addresses.map(InternetAddress.new).toList();
  }

  String? _tryBuild24BitBroadcast(String address) {
    final segments = address.split('.');
    if (segments.length != 4) {
      return null;
    }

    return '${segments[0]}.${segments[1]}.${segments[2]}.255';
  }
}
