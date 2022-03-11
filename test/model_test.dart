import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rdp_flutter/model.dart';

void main() {
  test('ServerItem.fromJson', () async {
    final item = ServerItem.fromJson({
      'description': 'description',
      'url': 'url',
      'token': 'token',
    });
    expect(item.description, 'description');
    expect(item.url, 'url');
    expect(item.token, 'token');
  });
  test('ServerItem.toJson', () {
    final item = ServerItem(
      description: 'description',
      url: 'url',
      token: 'token',
    );
    expect(item.toJson(), {
      'description': 'description',
      'url': 'url',
      'token': 'token',
    });
  });
  test('ServerItem displays', () {
    final item = ServerItem(
      description: 'description',
      url: 'url',
      token: 'token',
    );
    expect(item.title(), 'description');
    expect(item.subtitle(), 'url');
    expect(item.inlineDescription(), 'description(url)');

    final item2 = ServerItem(
      url: 'url',
    );
    expect(item2.title(), 'url');
    expect(item2.subtitle(), '');
    expect(item2.inlineDescription(), 'url');
  });

  test('ServerList.fromJson', () {
    final list = ServerList.fromJson(
        '''{
      "server_list": [
        {
          "description": "description",
          "url": "url",
          "token": "token"
        }
      ],
      "selected": 0
    }''');
    expect(list.items.length, 1);
    expect(list.items[0].description, 'description');
    expect(list.items[0].url, 'url');
    expect(list.items[0].token, 'token');
    expect(list.selected, list.items[0]);
  });

  test('ServerList.toJson', () {
    final item = ServerItem(
      description: 'description',
      url: 'url',
      token: 'token',
    );
    final list = ServerList(
      items: [
        item,
      ],
      selected: item,
    );
    expect(json.encode(list),
        '{"server_list":[{"description":"description","url":"url","token":"token"}],"selected":0}');
  });
}
