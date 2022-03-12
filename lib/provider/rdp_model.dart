import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RDPProvider extends StatelessWidget {
  final ServerItem server;
  final Widget? child;

  const RDPProvider({Key? key, required this.server, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => RDPModel(server: server), child: child);
  }
}

class RDPModel extends ChangeNotifier {
  final ServerItem server;

  RDPModel({required this.server}) : super();

  WebSocketChannel connections() {
    final channel = WebSocketChannel.connect(Uri.parse(
        '${server.url.replaceFirst('http', 'ws')}/api/stream/connection'));
    return channel;
  }
}
