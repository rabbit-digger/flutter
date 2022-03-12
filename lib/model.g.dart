// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionMessage _$ConnectionMessageFromJson(Map<String, dynamic> json) =>
    ConnectionMessage(
      json['full'] == null
          ? null
          : ConnectionState.fromJson(json['full'] as Map<String, dynamic>),
      (json['patch'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ConnectionMessageToJson(ConnectionMessage instance) =>
    <String, dynamic>{
      'full': instance.full,
      'patch': instance.patch,
    };

ConnectionState _$ConnectionStateFromJson(Map<String, dynamic> json) =>
    ConnectionState(
      totalUpload: json['total_upload'] as int? ?? 0,
      totalDownload: json['total_download'] as int? ?? 0,
      connections: (json['connections'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Connection.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ConnectionStateToJson(ConnectionState instance) =>
    <String, dynamic>{
      'total_upload': instance.totalUpload,
      'total_download': instance.totalDownload,
      'connections': instance.connections,
    };

Connection _$ConnectionFromJson(Map<String, dynamic> json) => Connection(
      json['protocol'] as String,
      json['addr'] as String,
      json['start_time'] as int,
      json['upload'] as int,
      json['download'] as int,
      json['ctx'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ConnectionToJson(Connection instance) =>
    <String, dynamic>{
      'protocol': instance.protocol,
      'addr': instance.addr,
      'start_time': instance.startTime,
      'upload': instance.upload,
      'download': instance.download,
      'ctx': instance.ctx,
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
