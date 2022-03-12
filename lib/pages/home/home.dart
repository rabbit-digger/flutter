import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/pages/server_selector.dart';

import 'tabs/dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.watch<SelectServer>().clear,
        ),
      ),
      body: const Dashboard(),
    );
  }
}
