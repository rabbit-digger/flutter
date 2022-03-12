import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/pages/server_selector/server_selector.dart';

import 'home.i18n.dart';
import 'tabs/dashboard.dart';
import 'tabs/connections.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Dashboard(),
    Text(
      'Select',
      style: optionStyle,
    ),
    Text(
      'Config',
      style: optionStyle,
    ),
    ConnectionView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.area_chart),
            label: 'Dashboard'.i18n,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_tree),
            label: 'Select'.i18n,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: 'Config'.i18n,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.link),
            label: 'Connections'.i18n,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
