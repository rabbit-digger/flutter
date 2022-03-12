import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/model.dart' as model;
import 'package:web_socket_channel/web_socket_channel.dart';

class RDPProvider extends StatelessWidget {
  final model.ServerItem server;
  final Widget? child;

  const RDPProvider({Key? key, required this.server, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => RDPConnections(server: server), child: child);
  }
}

class RDPConnections extends ChangeNotifier {
  final model.ServerItem server;
  WebSocketChannel? _channel;
  model.ConnectionState _state = model.ConnectionState();

  RDPConnections({required this.server}) : super() {
    final channel = WebSocketChannel.connect(Uri.parse(
        '${server.url.replaceFirst('http', 'ws')}/api/stream/connection'));
    channel.stream
        .map((event) => model.ConnectionMessage.fromJson(jsonDecode(event)))
        .listen(
      (msg) {
        _state += msg;
        notifyListeners();
      },
    );
    _channel = channel;
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  model.ConnectionState get state => _state;
}
