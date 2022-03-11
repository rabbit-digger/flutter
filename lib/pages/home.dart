import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/pages/server_selector.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final setSelected = Provider.of<SetSelected>(context);

    return Consumer<RDPModel>(builder: (context, rdp, child) {
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
              Text('Content: ' + rdp.server.inlineDescription()),
            ],
          ),
        ),
      );
    });
  }
}
