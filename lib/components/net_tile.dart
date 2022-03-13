import 'package:flutter/material.dart';

const double height = 80;

class NetTile extends StatelessWidget {
  final String title;
  final bool? active;
  final void Function()? onTap;

  const NetTile({Key? key, required this.title, this.active, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active == true
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium!.color;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
              minWidth: 120,
              maxWidth: 180,
              minHeight: height,
              maxHeight: height),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: TextStyle(color: color),
          ),
        ),
      ),
    );
  }
}
