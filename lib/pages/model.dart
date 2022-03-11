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

  ServerList(this.items);

  static ServerList fromJson(String text) {
    try {
      Iterable l = json.decode(text);
      final items =
          List<ServerItem>.from(l.map((model) => ServerItem.fromJson(model)));
      return ServerList(items);
    } catch (e) {
      if (kDebugMode) {
        print('ServerList.fromJson: $e');
      }
      return ServerList([]);
    }
  }

  List<ServerItem> toJson() => items;

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
