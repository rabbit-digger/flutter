import 'package:flutter/material.dart';
import 'package:rdp_flutter/components/common_page_view.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonPageView(
      children: <Widget>[
        DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Text('Name'),
            ),
            DataColumn(
              label: Text('Age'),
            ),
            DataColumn(
              label: Text('Role'),
            ),
          ],
          rows: const <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Sarah')),
                DataCell(Text('19')),
                DataCell(Text('Student')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Janine')),
                DataCell(Text('43')),
                DataCell(Text('Professor')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('William')),
                DataCell(Text('27')),
                DataCell(Text('Associate Professor')),
              ],
            ),
          ],
        )
      ],
    );
  }
}
