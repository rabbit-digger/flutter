import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/components/common_page_view.dart';
import 'package:rdp_flutter/provider/rdp_model.dart' as model;

import 'connections.i18n.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ConnectionView extends StatefulWidget {
  const ConnectionView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionViewState();
}

class _ConnectionViewState extends State<ConnectionView> {
  late ConnectionDataSource _source;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Locale locale = Localizations.localeOf(context);
    _source = ConnectionDataSource(context.read<model.RDPConnections>(),
        locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    return FillPageView(
      child: SfDataGrid(
        columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
        headerRowHeight: 40,
        rowHeight: 40,
        columnWidthMode: ColumnWidthMode.fitByCellValue,
        columns: _dataColumn,
        source: _source,
      ),
    );
  }

  static final _dataColumn = <GridColumn>[
    GridColumn(
      columnName: 'address',
      autoFitPadding: const EdgeInsets.all(8.0),
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text('Address'.i18n),
      ),
    ),
    GridColumn(
      columnName: 'dowonload',
      width: 100,
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerRight,
        child: Text('Download'.i18n),
      ),
    ),
    GridColumn(
      columnName: 'upload',
      width: 100,
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerRight,
        child: Text('Upload'.i18n),
      ),
    ),
    GridColumn(
      columnName: 'startTime',
      width: 120,
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerRight,
        child: Text('Start Time'.i18n),
      ),
    ),
    GridColumn(
      columnName: 'source',
      autoFitPadding: const EdgeInsets.all(8.0),
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerRight,
        child: Text('Source Address'.i18n),
      ),
    ),
    GridColumn(
      columnName: 'destIp',
      autoFitPadding: const EdgeInsets.all(8.0),
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerRight,
        child: Text('Destination IP'.i18n),
      ),
    ),
    GridColumn(
      columnName: 'serverProtocol',
      width: 120,
      label: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerRight,
        child: Text('Server(Protocol)'.i18n),
      ),
    ),
  ];
}

class ConnectionDataSource extends DataGridSource {
  model.RDPConnections conns;
  Locale? locale;

  ConnectionDataSource(this.conns, {this.locale}) : super() {
    conns.addListener(_onChange);
    _onChange();
  }

  List<DataGridRow> dataGridRows = <DataGridRow>[];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final cells = row.getCells();
    return DataGridRowAdapter(
      cells: <Widget>[
        CellText(
          cells[0].value.toString(),
          alignment: Alignment.centerLeft,
        ),
        CellText(
          cells[1].value.toString(),
          alignment: Alignment.centerRight,
        ),
        CellText(
          cells[2].value.toString(),
          alignment: Alignment.centerRight,
        ),
        CellText(
          cells[3].value.toString(),
          alignment: Alignment.centerRight,
        ),
        CellText(
          cells[4].value.toString(),
          alignment: Alignment.centerRight,
        ),
        CellText(
          cells[5].value.toString(),
          alignment: Alignment.centerRight,
        ),
        CellText(
          cells[6].value.toString(),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }

  @override
  void dispose() {
    conns.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final entries = conns.state.connections?.entries.toList() ?? [];
    final now = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round();
    entries.sort(_sortConn);

    dataGridRows = entries
        .map((e) => e.value)
        .map(
          (value) => DataGridRow(
            cells: <DataGridCell>[
              DataGridCell<String>(
                  columnName: 'address', value: value.targetAddress),
              DataGridCell<String>(
                  columnName: 'download', value: filesize(value.download)),
              DataGridCell<String>(
                  columnName: 'upload', value: filesize(value.upload)),
              DataGridCell<String>(
                columnName: 'startTime',
                value: '%s ago'.i18n.fill([
                  prettyDuration(
                    Duration(
                      seconds: now - value.startTime,
                    ),
                    abbreviated: true,
                    tersity: DurationTersity.minute,
                    upperTersity: DurationTersity.day,
                    locale: DurationLocale.fromLanguageCode(
                            locale?.languageCode ?? 'en') ??
                        const EnglishDurationLocale(),
                  )
                ]),
              ),
              DataGridCell<String>(
                  columnName: 'source', value: value.srcAddress),
              DataGridCell<String>(
                  columnName: 'destIp',
                  value: addr2host(value.context.destSocketAddr != null
                      ? value.context.destSocketAddr!
                      : value.addr)),
              DataGridCell<String>(
                  columnName: 'serverProtocol',
                  value: '${value.context.netList[0]}(${value.protocol})'),
            ],
          ),
        )
        .toList();
    notifyListeners();
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

class CellText extends StatelessWidget {
  final String text;
  final Alignment? alignment;

  const CellText(this.text, {Key? key, this.alignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}

String addr2host(String addr) {
  final parts = addr.split(':');
  final host = parts.sublist(0, parts.length - 1).join(':');
  return host;
}
