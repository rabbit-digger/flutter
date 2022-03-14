import 'package:flutter/material.dart';
import 'package:rdp_flutter/utils/is_tablet.dart';

class CommonPageView extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onFetch;

  const CommonPageView({Key? key, required this.children, this.onFetch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshView(
      onFetch: onFetch,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(context.isTablet ? 16 : 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class FillPageView extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onFetch;

  const FillPageView({Key? key, required this.child, this.onFetch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshView(
      onFetch: onFetch,
      child: Container(
        padding: EdgeInsets.all(context.isTablet ? 16 : 4),
        child: child,
      ),
    );
  }
}

class RefreshView extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onFetch;

  const RefreshView({
    Key? key,
    required this.child,
    this.onFetch,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RefreshViewState();
}

class _RefreshViewState extends State<RefreshView> {
  @override
  Widget build(BuildContext context) {
    return widget.onFetch != null
        ? RefreshIndicator(
            onRefresh: widget.onFetch!,
            child: widget.child,
          )
        : widget.child;
  }
}
