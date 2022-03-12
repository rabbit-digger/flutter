import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/model.dart' as model;
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum RDPState {
  connecting,
  connected,
  disconnected,
  error,
}

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

class RDPSummary {
  final int downloadPerSecond;
  final int uploadPerSecond;
  final int downloadTotal;
  final int uploadTotal;
  final int connectionCount;

  const RDPSummary(
      {this.downloadPerSecond = 0,
      this.uploadPerSecond = 0,
      this.downloadTotal = 0,
      this.uploadTotal = 0,
      this.connectionCount = 0});
}

class RDPConnections extends ChangeNotifier {
  final model.ServerItem server;
  int _count = 0;
  RDPState _channesState = RDPState.connecting;
  WebSocketChannel? _channel;
  model.ConnectionState? _lastState;
  model.ConnectionState _state = model.ConnectionState();
  final List<RDPSummary> _lastMinute =
      List.filled(60, const RDPSummary(), growable: true);

  RDPConnections({required this.server}) : super() {
    final channel = WebSocketChannel.connect(Uri.parse(
        '${server.url.replaceFirst('http', 'ws')}/api/stream/connection'));
    final sub = channel.stream
        .map((event) => model.ConnectionMessage.fromJson(jsonDecode(event)))
        .scan((model.ConnectionState state, i, _) => state + i,
            model.ConnectionState())
        .listen(
      (state) {
        _count += 1;
        _channesState = RDPState.connected;
        _lastState = _lastState == null ? state : _state;
        _state = state;

        _lastMinute.add(summary);
        while (_lastMinute.length > 60) {
          _lastMinute.removeAt(0);
        }
        notifyListeners();
      },
    );

    sub.onDone(() {
      _channesState = RDPState.disconnected;
      notifyListeners();
    });
    sub.onError((e) {
      _channesState = RDPState.error;
      notifyListeners();
    });

    _channel = channel;
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  List<RDPSummary> get lastMinute => _lastMinute;
  RDPState get channelState => _channesState;

  int get count => _count;
  model.ConnectionState get state => _state;
  RDPSummary get summary => RDPSummary(
      downloadPerSecond: _lastState != null
          ? _state.totalDownload - _lastState!.totalDownload
          : 0,
      uploadPerSecond:
          _lastState != null ? _state.totalUpload - _lastState!.totalUpload : 0,
      downloadTotal: _state.totalDownload,
      uploadTotal: _state.totalUpload,
      connectionCount: _state.connections?.length ?? 0);
}
