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
  RDPConfig? _config;
  @override
  Widget build(BuildContext context) {
    final config = context.watch<RDPConfig>();
    _config = config;
    final selectNet = config
        .queryNet(type: 'select')
        .mapValue((i) => i.toNet(SelectNet.fromJson));

    return CommonPageView(
      children: <Widget>[
        ...selectNet.entries.mapIndexed((index, e) {
          return ExpansionTile(
            title: Text(e.key),
            subtitle: Text(e.value.selected),
            children: [
              PanelBody(
                  key: ValueKey(index),
                  net: e.value,
                  onSelect: (select) => _onSelect(e.key, select))
            ],
          );
        })
      ],
    );
  }

  void _onSelect(String net, String select) async {
    await _config?.setSelect(net, select);
  }
}

class PanelBody extends StatelessWidget {
  final SelectNet net;
  final void Function(String)? onSelect;

  const PanelBody({Key? key, required this.net, this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: net.list
            .map((i) => NetTile(
                key: ValueKey(i),
                title: i,
                active: i == net.selected,
                onTap: () => onSelect?.call(i)))
            .toList(),
      ),
    );
  }
}
