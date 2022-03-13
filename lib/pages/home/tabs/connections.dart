import 'package:duration/duration.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/components/common_page_view.dart';
import 'package:rdp_flutter/provider/rdp_model.dart' as model;

import 'package:i18n_extension/default.i18n.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonPageView(
      children: <Widget>[
        DataTable(
          columns: _dataColumn,
          rows: _rows(context),
        )
      ],
    );
  }

  static final _dataColumn = <DataColumn>[
    DataColumn(
      label: Text('Address'.i18n),
    ),
    DataColumn(
      label: Text('Download'.i18n),
    ),
    DataColumn(
      label: Text('Upload'.i18n),
    ),
    DataColumn(
      label: Text('Start Time'.i18n),
    ),
  ];

  List<DataRow> _rows(BuildContext context) {
    final conns = context.watch<model.RDPConnections>();
    final entries = conns.state.connections?.entries.toList() ?? [];

    entries.sort(_sortConn);
    return entries.map(_buildItem).toList();
  }

  DataRow _buildItem(MapEntry<String, model.Connection> entry) {
    final key = entry.key;
    final conn = entry.value;
    return DataRow(
      key: ValueKey(key),
      cells: <DataCell>[
        DataCell(
          Text(conn.targetAddress),
        ),
        DataCell(
          Text(filesize(conn.download)),
        ),
        DataCell(
          Text(filesize(conn.upload)),
        ),
        DataCell(
          Text(prettyDuration(
              Duration(
                  seconds:
                      (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
                              .round() -
                          conn.startTime),
              abbreviated: true,
              upperTersity: DurationTersity.day)),
        )
      ],
    );
  }

  int _sortConn(MapEntry<String, model.Connection> a,
      MapEntry<String, model.Connection> b) {
    var d = b.value.startTime - a.value.startTime;
    if (d != 0) {
      return d;
    }
    return b.key.compareTo(a.key);
  }
}
