import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/components/common_page_view.dart';
import 'package:rdp_flutter/components/number_board.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conns = context.watch<RDPConnections>();

    return CommonPageView(
      children: <Widget>[
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: <Widget>[
            NumberBoard.fileSize(
                title: 'Total download', size: conns.state.totalDownload),
            NumberBoard.fileSize(
                title: 'Total upload', size: conns.state.totalUpload),
            NumberBoard.fileSize(
              title: 'Download speed',
              size: conns.summary.downloadPerSecond,
              unitFormatter: appendPerSec,
            ),
            NumberBoard.fileSize(
              title: 'Upload speed',
              size: conns.summary.uploadPerSecond,
              unitFormatter: appendPerSec,
            ),
            NumberBoard(
              title: 'Connections',
              value: conns.summary.connectionCount.toString(),
            )
          ],
        ),
        SizedBox(
          height: 400,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: NumericAxis(
              interval: 5,
              majorGridLines: const MajorGridLines(width: 0),
              labelFormat: '{value}s',
            ),
            primaryYAxis: NumericAxis(
              majorTickLines: const MajorTickLines(color: Colors.transparent),
              axisLine: const AxisLine(width: 0),
              minimum: 0,
              axisLabelFormatter: (i) =>
                  ChartAxisLabel('${filesize(i.value.round())}/s', null),
            ),
            series: seriesList(conns),
            legend: Legend(
              position: LegendPosition.top,
              isVisible: true,
              iconHeight: 20,
              iconWidth: 20,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
          ),
        ),
      ],
    );
  }
}

List<AreaSeries<RDPSummary, num>> seriesList(RDPConnections conns) {
  return [
    AreaSeries<RDPSummary, int>(
      legendItemText: 'Download',
      xValueMapper: (summary, i) => conns.count + i - 60,
      yValueMapper: (summary, _) => summary.downloadPerSecond,
      dataSource: conns.lastMinute,
      animationDuration: 0,
      color: const Color.fromARGB(128, 23, 93, 159),
    ),
    AreaSeries<RDPSummary, int>(
      legendItemText: 'Upload',
      xValueMapper: (summary, i) => conns.count + i - 60,
      yValueMapper: (summary, _) => summary.uploadPerSecond,
      dataSource: conns.lastMinute,
      animationDuration: 0,
      color: const Color.fromARGB(128, 238, 220, 63),
    )
  ];
}

String appendPerSec(String value) {
  return '$value/s';
}