import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_patch/json_patch.dart';

part 'model.g.dart';

const String serverKey = 'server_list';

@JsonSerializable()
class ConnectionMessage {
  final ConnectionState? full;
  final List<Map<String, dynamic>>? patch;

  ConnectionMessage(this.full, this.patch);

  factory ConnectionMessage.fromJson(Map<String, dynamic> json) =>
      _$ConnectionMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionMessageToJson(this);
}

@JsonSerializable()
class ConnectionState {
  @JsonKey(name: 'total_upload')
  final int totalUpload;
  @JsonKey(name: 'total_download')
  final int totalDownload;
  final Map<String, Connection>? connections;

  ConnectionState(
      {this.totalUpload = 0, this.totalDownload = 0, this.connections});

  factory ConnectionState.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStateFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionStateToJson(this);

  ConnectionState operator +(ConnectionMessage other) {
    if (other.full != null) {
      return other.full!;
    }
    if (other.patch == null) {
      return this;
    }
    final patched = JsonPatch.apply(toJson(), other.patch!);
    return ConnectionState.fromJson(patched);
  }
}

class ConnContext {
  final Map<String, dynamic> ctx;

  const ConnContext(this.ctx);

  String? get srcSocketAddr => ctx['src_socket_addr'];
  String? get destSocketAddr => ctx['dest_socket_addr'];
  String? get destDomain => ctx['dest_domain'];
  List<String> get netList {
    final netList = ctx['net_list'] as List<dynamic>? ?? [];
    return netList.map((e) => e.toString()).toList();
  }
}

@JsonSerializable()
class Connection {
  final String protocol;
  final String addr;
  @JsonKey(name: 'start_time')
  final int startTime;
  final int upload;
  final int download;
  @JsonKey(name: 'ctx')
  final Map<String, dynamic> ctx;

  Connection(this.protocol, this.addr, this.startTime, this.upload,
      this.download, this.ctx);

  factory Connection.fromJson(Map<String, dynamic> json) =>
      _$ConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionToJson(this);

  ConnContext get context => ConnContext(ctx);
  String get targetAddress => context.destDomain ?? addr;
  String get srcAddress => context.srcSocketAddr ?? 'N/A';
}

@JsonSerializable()
class SelectNet {
  List<String> list;
  String selected;

  SelectNet({required this.list, required this.selected});

  factory SelectNet.fromJson(Map<String, dynamic> json) =>
      _$SelectNetFromJson(json);

  Map<String, dynamic> toJson() => _$SelectNetToJson(this);
}

Map<String, dynamic> _omitKey(Map<String, dynamic> json, List<String> keys) {
  return Map.fromEntries(json.entries.where((e) => !keys.contains(e.key)));
}

typedef NetFactory<T> = T Function(Map<String, dynamic> json);

class RDPConfigItem {
  String type;
  Map<String, dynamic> opt;

  RDPConfigItem(this.type, this.opt);

  factory RDPConfigItem.fromJson(Map<String, dynamic> json) =>
      RDPConfigItem(json['type'] as String, _omitKey(json, ['type']));

  Map<String, dynamic> toJson() => {
        ...opt,
        'type': type,
      };

  T toNet<T>(NetFactory<T> factory) {
    return factory(opt);
  }
}

@JsonSerializable()
class RDPConfig {
  String? id;
  Map<String, RDPConfigItem>? net;
  Map<String, RDPConfigItem>? server;

  RDPConfig({this.net, this.server});

  factory RDPConfig.fromJson(Map<String, dynamic> json) =>
      _$RDPConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RDPConfigToJson(this);
}

@JsonSerializable()
class ServerItem {
  String? description;
  String url;
  String? token;

  ServerItem({required this.url, this.description, this.token});

  factory ServerItem.fromJson(Map<String, dynamic> json) =>
      _$ServerItemFromJson(json);

  Map<String, dynamic> toJson() => _$ServerItemToJson(this);

  String title() {
    return isEmpty(description) ? url : description!;
  }

  String subtitle() {
    return isEmpty(description) ? '' : url;
  }

  String inlineDescription() {
    return isEmpty(description) ? url : '$description($url)';
  }
}

class ServerList {
  final List<ServerItem> items;
  ServerItem? selected;

  ServerList({required this.items, this.selected});

  static ServerList fromJson(String text) {
    try {
      final obj = json.decode(text);
      int? selectedIndex = obj['selected'];
      Iterable l = obj['server_list'];
      final items =
          List<ServerItem>.from(l.map((model) => ServerItem.fromJson(model)));
      return ServerList(
          items: items,
          selected: selectedIndex != null ? items[selectedIndex] : null);
    } catch (e) {
      if (kDebugMode) {
        print('ServerList.fromJson: $e');
      }
      return ServerList(items: []);
    }
  }

  Map<String, dynamic> toJson() => {
        'server_list': items,
        'selected': selected != null ? items.indexOf(selected!) : null,
      };

  ServerItem? getSelected() {
    return selected;
  }

  setSelected(ServerItem? i) async {
    selected = i;
    return await save();
  }

  add(ServerItem i) async {
    items.add(i);
    return await save();
  }

  remove(ServerItem i) async {
    items.remove(i);
    return await save();
  }

  static Future<ServerList> load() async {
    final prefs = await SharedPreferences.getInstance();
    final items = ServerList.fromJson(prefs.getString(serverKey) ?? '[]');
    return items;
  }

  save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(serverKey, json.encode(this));
  }
}

bool isEmpty(String? s) => s?.isEmpty ?? true;
