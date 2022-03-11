import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String serverKey = 'server_list';

class ServerItem {
  String? description;
  String url;
  String? token;

  ServerItem({required this.url, this.description, this.token});

  ServerItem.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        url = json['url'],
        token = json['token'];

  Map<String, dynamic> toJson() => {
        'description': description,
        'url': url,
        'token': token,
      };

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
