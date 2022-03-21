import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/components/common_page_view.dart';
import 'package:rdp_flutter/provider/rdp_model.dart' as model;
import 'package:collection/collection.dart';

import 'connections.i18n.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

typedef ValueGetter<T> = dynamic Function(T data);
typedef Formatter = String Function(dynamic);
String defaultFormatter(dynamic i) => i.toString();

class ColumnDefinition<T> {
  final String columnName;

  final Formatter formatter;
  final ValueGetter<T> value;
  final String label;
  final Alignment alignment;
  final ColumnWidthMode columnWidthMode;
  final double width;
  final double minimumWidth;

  const ColumnDefinition({
    required this.columnName,
    required this.label,
    required this.value,
    this.alignment = Alignment.centerRight,
    this.columnWidthMode = ColumnWidthMode.none,
    this.formatter = defaultFormatter,
    this.width = double.nan,
    this.minimumWidth = double.nan,
  });
}

class RowData {
  final String address;
  final int download;
  final int upload;
  final int downloadSpeed;
  final int uploadSpeed;
  final int startTime;
  final String source;
  final String destIp;
  final String serverProtocol;

  RowData({
    required this.address,
    required this.download,
    required this.upload,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.startTime,
    required this.source,
    required this.destIp,
    required this.serverProtocol,
  });

  factory RowData.fromConn(model.Connection conn, model.Connection? last) {
    return RowData(
      address: conn.targetAddress,
      download: conn.download,
      upload: conn.upload,
      downloadSpeed: last == null ? 0 : (conn.download - last.download),
      uploadSpeed: last == null ? 0 : (conn.upload - last.upload),
      startTime: conn.startTime,
      source: conn.srcAddress,
      destIp: addr2host(conn.context.destSocketAddr != null
          ? conn.context.destSocketAddr!
          : conn.addr),
      serverProtocol: '${conn.context.netList[0]}(${conn.protocol})',
    );
  }
}

class ConnectionView extends StatefulWidget {
  const ConnectionView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectionViewState();
}

class _ConnectionViewState extends State<ConnectionView> {
  late ConnectionDataSource _source;
  late Locale? _locale;
  late List<ColumnDefinition<RowData>> _columns;
  late List<GridColumn> _dataColumn;

  List<ColumnDefinition<RowData>> _buildColumns() {
    return <ColumnDefinition<RowData>>[
      ColumnDefinition(
        columnName: 'address',
        label: 'Address'.i18n,
        value: (i) => i.address,
        alignment: Alignment.centerLeft,
        columnWidthMode: ColumnWidthMode.fitByCellValue,
      ),
      ColumnDefinition(
        columnName: 'download',
        label: 'Download'.i18n,
        value: (i) => i.download,
        formatter: (i) => filesize(i),
        minimumWidth: 120,
      ),
      ColumnDefinition(
        columnName: 'upload',
        label: 'Upload'.i18n,
        value: (i) => i.upload,
        formatter: (i) => filesize(i),
        minimumWidth: 120,
      ),
      ColumnDefinition(
        columnName: 'downloadSpeed',
        label: 'Download Speed'.i18n,
        value: (i) => i.downloadSpeed,
        formatter: (i) => filesize(i) + '/s',
        minimumWidth: 120,
      ),
      ColumnDefinition(
        columnName: 'uploadSpeed',
        label: 'Upload Speed'.i18n,
        value: (i) => i.uploadSpeed,
        formatter: (i) => filesize(i) + '/s',
        minimumWidth: 120,
      ),
      ColumnDefinition(
          columnName: 'startTime',
          label: 'Start Time'.i18n,
          value: (i) => i.startTime,
          minimumWidth: 120,
          formatter: (i) {
            var now =
                (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round();
            var readable = prettyDuration(
              Duration(
                seconds: now - i as int,
              ),
              abbreviated: true,
              tersity: DurationTersity.minute,
              upperTersity: DurationTersity.day,
              locale: DurationLocale.fromLanguageCode(
                      _locale?.languageCode ?? 'en') ??
                  const EnglishDurationLocale(),
            );
            return '%s ago'.i18n.fill([readable]);
          }),
      ColumnDefinition(
        columnName: 'source',
        label: 'Source Address'.i18n,
        value: (i) => i.source,
        columnWidthMode: ColumnWidthMode.fitByCellValue,
      ),
      ColumnDefinition(
        columnName: 'destIp',
        label: 'Destination IP'.i18n,
        value: (i) => i.destIp,
        columnWidthMode: ColumnWidthMode.fitByCellValue,
      ),
      ColumnDefinition(
        columnName: 'serverProtocol',
        label: 'Server(Protocol)'.i18n,
        value: (i) => i.serverProtocol,
        columnWidthMode: ColumnWidthMode.fitByCellValue,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _locale = Localizations.localeOf(context);
    _columns = _buildColumns();
    _dataColumn = _columns
        .map((c) => GridColumn(
            columnName: c.columnName,
            columnWidthMode: c.columnWidthMode,
            width: c.width,
            minimumWidth: c.minimumWidth,
            autoFitPadding: const EdgeInsets.all(8),
            label: Container(
              padding: const EdgeInsets.all(8),
              alignment: c.alignment,
              child: Text(
                c.label,
              ),
            )))
        .toList();
    _source = ConnectionDataSource(context.read<model.RDPConnections>(),
        columns: _columns);
  }

  @override
  Widget build(BuildContext context) {
    final conns = context.watch<model.RDPConnections>();

    if (conns.channelState == model.RDPChannelState.connecting) {
      return const Center(child: CircularProgressIndicator());
    }

    return FillPageView(
      child: SfDataGrid(
        columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
        headerRowHeight: 40,
        rowHeight: 40,
        columnWidthMode: ColumnWidthMode.fitByCellValue,
        columns: _dataColumn,
        source: _source,
        allowSorting: true,
      ),
    );
  }
}

class ConnectionDataSource extends DataGridSource {
  model.RDPConnections conns;
  List<ColumnDefinition<RowData>> columns;

  ConnectionDataSource(this.conns, {required this.columns}) : super() {
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
      cells: columns
          .mapIndexed((i, c) => CellText(
                c.formatter(cells[i].value),
                alignment: c.alignment,
              ))
          .toList(),
    );
  }

  @override
  void dispose() {
    conns.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final entries = conns.state.connections?.entries.toList() ?? [];
    entries.sort(_sortConn);

    dataGridRows = entries.map(
      (e) {
        final value = e.value;
        final last = conns.lastState?.connections?[e.key];
        final row = RowData.fromConn(value, last);

        return DataGridRow(
          cells: columns
              .map((c) =>
                  DataGridCell(columnName: c.columnName, value: c.value(row)))
              .toList(),
        );
      },
    ).toList();

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
