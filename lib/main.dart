import 'package:flutter/material.dart';
import 'package:rdp_flutter/pages/home/home.dart';
import 'package:rdp_flutter/pages/server_selector/server_selector.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

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
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
      ],
      home: I18n(
        child: ServerSelector(
          builder: (server) => RDPProvider(
            server: server,
            child: HomePage(title: server.inlineDescription()),
          ),
        ),
      ),
    );
  }
}
