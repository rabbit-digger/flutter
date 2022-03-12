import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdp_flutter/components/number_board.dart';
import 'package:rdp_flutter/pages/server_selector.dart';
import 'package:rdp_flutter/provider/rdp_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final conns = context.watch<RDPConnections>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.watch<SelectServer>().clear,
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      size: conns.summary.downloadPerSecond),
                  NumberBoard.fileSize(
                      title: 'Upload speed',
                      size: conns.summary.uploadPerSecond),
                  NumberBoard(
                      title: 'Connections',
                      value: conns.summary.connectionCount.toString())
                ]),
            SizedBox(
              height: 400,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: NumericAxis(
                    interval: 5,
                    majorGridLines: const MajorGridLines(width: 0),
                    labelFormat: '{value}s'),
                primaryYAxis: NumericAxis(
                  majorTickLines:
                      const MajorTickLines(color: Colors.transparent),
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
                    overflowMode: LegendItemOverflowMode.wrap),
              ),
            ),
          ],
        ),
      )),
    );
  }

  List<AreaSeries<RDPSummary, num>> seriesList(RDPConnections conns) {
    return [
      AreaSeries<RDPSummary, int>(
        legendItemText: 'Download',
        xValueMapper: (RDPSummary summary, i) => conns.count + i - 60,
        yValueMapper: (RDPSummary summary, _) => summary.downloadPerSecond,
        dataSource: conns.lastMinute,
        animationDuration: 0,
      ),
      AreaSeries<RDPSummary, int>(
        legendItemText: 'Upload',
        xValueMapper: (RDPSummary summary, i) => conns.count + i - 60,
        yValueMapper: (RDPSummary summary, _) => summary.uploadPerSecond,
        dataSource: conns.lastMinute,
        animationDuration: 0,
      )
    ];
  }
}
