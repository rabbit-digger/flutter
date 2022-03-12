import 'package:flutter/foundation.dart';
import 'package:rdp_flutter/model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RDPModel extends ChangeNotifier {
  final ServerItem server;
  late final channel = IOWebSocketChannel.connect(server.url);

  RDPModel({required this.server}) : super();
}
