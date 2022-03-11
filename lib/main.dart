import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/pages/home.dart';
import 'package:rdp_flutter/pages/server_selector.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final globalPrefs = SharedPreferences.getInstance();

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Rabbit Digger Pro',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: ServerSelector(
          builder: (server) => ChangeNotifierProvider(
              create: (context) => RDPModel(server: server),
              child: Consumer<RDPModel>(
                builder: (context, value, child) =>
                    HomePage(title: value.server.inlineDescription()),
              )),
        ));
  }
}
