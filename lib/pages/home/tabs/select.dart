import 'package:flutter/material.dart';
import 'package:rdp_flutter/components/common_page_view.dart';
import 'package:rdp_flutter/components/net_tile.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/utils/map_value.dart';
import 'package:collection/collection.dart';

class SelectView extends StatefulWidget {
  const SelectView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectViewState();
}

class _SelectViewState extends State<SelectView> {
  final Map<int, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RDPConfig>();
    final selectNet = config
        .queryNet(type: 'select')
        .mapValue((i) => i.toNet(SelectNet.fromJson));

    return CommonPageView(
      children: <Widget>[
        ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            _toggleExpanded(index, isExpanded: isExpanded);
          },
          children: selectNet.entries.mapIndexed((index, e) {
            return ExpansionPanel(
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(e.key),
                );
              },
              body: SizedBox(
                  width: double.infinity,
                  child: PanelBody(key: ValueKey(index), net: e.value)),
              isExpanded: _expanded[index] ?? false,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _toggleExpanded(int index, {bool? isExpanded}) {
    setState(() {
      _expanded[index] = !(_expanded[index] ?? false);
    });
  }
}

class PanelBody extends StatelessWidget {
  final SelectNet net;

  const PanelBody({Key? key, required this.net}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      children: net.list
          .map((i) =>
              NetTile(key: ValueKey(i), title: i, active: i == net.selected))
          .toList(),
    );
  }
}
