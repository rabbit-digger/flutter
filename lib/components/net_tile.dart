import 'package:flutter/material.dart';

class NetTile extends StatelessWidget {
  final String title;
  final bool? active;

  const NetTile({Key? key, required this.title, this.active}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 120,
          child: ListTile(
            title: Text(title),
          ),
        ),
      ),
    );
  }
}
