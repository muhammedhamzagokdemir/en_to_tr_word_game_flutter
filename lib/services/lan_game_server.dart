import 'lan_game_server_base.dart';
import 'lan_game_server_stub.dart'
    if (dart.library.io) 'lan_game_server_io.dart'
    as impl;

LanGameServerBase createLanGameServer() => impl.createLanGameServer();
