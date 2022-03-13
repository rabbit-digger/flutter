import 'package:flutter/material.dart';
import 'package:rdp_flutter/utils/is_tablet.dart';

class CommonPageView extends StatelessWidget {
  final List<Widget> children;

  const CommonPageView({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(context.isTablet ? 16 : 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class FillPageView extends StatelessWidget {
  final Widget child;

  const FillPageView({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.isTablet ? 16 : 4),
      child: child,
    );
  }
}
