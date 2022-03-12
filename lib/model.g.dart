// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Connection _$ConnectionFromJson(Map<String, dynamic> json) => Connection(
      json['id'] as String,
    );

Map<String, dynamic> _$ConnectionToJson(Connection instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

ServerItem _$ServerItemFromJson(Map<String, dynamic> json) => ServerItem(
      url: json['url'] as String,
      description: json['description'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$ServerItemToJson(ServerItem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'url': instance.url,
      'token': instance.token,
    };
