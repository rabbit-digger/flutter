import 'package:flutter/material.dart';
import 'package:rdp_flutter/components/common_page_view.dart';
import 'package:rdp_flutter/components/net_tile.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/utils/map_value.dart';

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
    final entry = selectNet.entries.toList();

    return FillPageView(
      onFetch: config.refetch,
      child: ListView.builder(
        itemCount: entry.length,
        itemBuilder: (context, index) {
          final e = entry[index];
          return ListTile(
            title: Text(e.key),
            subtitle: Text(e.value.selected),
            trailing: const Icon(Icons.arrow_right),
            onTap: () async {
              String? selected = await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return NetSelector(title: e.key, net: e.value);
              }));
              if (selected != null) {
                _onSelect(e.key, selected);
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _onSelect(String net, String select) async {
    await _config?.setSelect(net, select);
  }
}

class NetSelector extends StatefulWidget {
  final String title;
  final SelectNet net;

  const NetSelector({Key? key, required this.net, required this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NetSelectorState();
}

class _NetSelectorState extends State<NetSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PanelBody(
          net: widget.net,
          onSelect: (net) {
            Navigator.of(context).pop(net);
          }),
    );
  }
}

class PanelBody extends StatelessWidget {
  final SelectNet net;
  final void Function(String)? onSelect;

  const PanelBody({Key? key, required this.net, this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ListView.build here seems to be useless, since it's not scrollable.
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final columnCount = (constraints.maxWidth / 160).floor();
      final list = net.list + List.filled(columnCount, '');

      return Container(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: (net.list.length / columnCount).ceil(),
          itemBuilder: (BuildContext context, int index) => Row(
            children: list
                .skip(index * columnCount)
                .take(columnCount)
                .map((i) => Expanded(
                      child: i == ''
                          ? Container()
                          : NetTile(
                              title: i,
                              active: i == net.selected,
                              onTap: () {
                                onSelect?.call(i);
                              },
                            ),
                    ))
                .toList(),
          ),
        ),
      );
    });
  }
}
