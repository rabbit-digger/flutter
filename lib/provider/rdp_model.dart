import 'package:flutter/foundation.dart';
import 'package:rdp_flutter/model.dart';

class RDPModel extends ChangeNotifier {
  final ServerItem server;

  RDPModel({required this.server}) : super();
}
