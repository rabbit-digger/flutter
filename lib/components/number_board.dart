import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

typedef Formatter = String Function(String value);

class NumberBoard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;

  const NumberBoard(
      {Key? key, required this.value, this.unit, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.caption),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(value, style: Theme.of(context).textTheme.headline6),
                  const SizedBox(width: 8),
                  Text(unit ?? '', style: Theme.of(context).textTheme.headline6)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  factory NumberBoard.fileSize(
      {required int size, required String title, Formatter? unitFormatter}) {
    final str = filesize(size);
    final list = str.split(' ');
    final formatter = unitFormatter ?? (value) => value;
    return NumberBoard(
      title: title,
      value: list[0],
      unit: formatter(list[1]),
    );
  }
}
