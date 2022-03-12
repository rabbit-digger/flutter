import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/pages/server_selector.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final rdp = Provider.of<RDPModel>(context);
    _channel = rdp.connections();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setSelected = Provider.of<SetSelected>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setSelected.set(null);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Content: ' +
                context.watch<RDPModel>().server.inlineDescription()),
          ],
        ),
      ),
    );
  }
}
