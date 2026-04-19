import 'lan_game_client_base.dart';
import 'lan_game_client_stub.dart'
    if (dart.library.io) 'lan_game_client_io.dart'
    as impl;

LanGameClientBase createLanGameClient() => impl.createLanGameClient();
