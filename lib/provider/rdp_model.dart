import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/model.dart' as model;
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

export 'package:rdp_flutter/model.dart';

enum RDPChannelState {
  connecting,
  connected,
  disconnected,
  error,
}

enum RDPAPIState {
  fetching,
  fetched,
  error,
}

class RDPProvider extends StatelessWidget {
  final model.ServerItem server;
  final Widget? child;

  const RDPProvider({Key? key, required this.server, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RDPConnections(server: server),
        ),
        ChangeNotifierProvider(
          create: (context) => RDPConfig(server: server),
        ),
      ],
      child: child,
    );
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

class RDPConfig extends ChangeNotifier {
  final model.ServerItem server;
  model.RDPConfig? _config;

  RDPAPIState _apiState = RDPAPIState.fetching;

  RDPConfig({required this.server}) : super() {
    _request();
  }

  Future<void> refetch() async {
    await _request();
  }

  Map<String, model.RDPConfigItem> queryNet({String? type}) {
    final net = _config?.net ?? {};
    if (type == null) {
      return net;
    }
    return Map.fromEntries(net.entries.where((e) => e.value.type == type));
  }

  Map<String, model.RDPConfigItem> queryServer({String? type}) {
    final server = _config?.server ?? {};
    if (type == null) {
      return server;
    }
    return Map.fromEntries(server.entries.where((e) => e.value.type == type));
  }

  Future<void> _request() async {
    try {
      _apiState = RDPAPIState.fetching;

      final resp = await http.get(Uri.parse('${server.url}/api/config'));
      final config =
          model.RDPConfig.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));

      _config = config;
      _apiState = RDPAPIState.fetched;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('request error: $e');
      }
      _apiState = RDPAPIState.error;
    }
  }

  Future<void> setSelect(String net, String select) async {
    await http.post(
        Uri.parse('${server.url}/api/net/${Uri.encodeComponent(net)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'selected': select,
        }));
    await refetch();
  }

  model.RDPConfig? get config => _config;
  RDPAPIState get apiState => _apiState;
}

class RDPConnections extends ChangeNotifier {
  final model.ServerItem server;

  int _count = 0;
  RDPChannelState _channelState = RDPChannelState.connecting;
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
        _channelState = RDPChannelState.connected;
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
      _channelState = RDPChannelState.disconnected;
      notifyListeners();
    });
    sub.onError((e) {
      _channelState = RDPChannelState.error;
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
  RDPChannelState get channelState => _channelState;

  int get count => _count;
  model.ConnectionState? get lastState => _lastState;
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
