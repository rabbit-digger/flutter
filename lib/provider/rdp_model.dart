import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class RDPModel extends ChangeNotifier {
  final String _content;
  String get content => _content;
  RDPModel(String content)
      : _content = content,
        super();
}
