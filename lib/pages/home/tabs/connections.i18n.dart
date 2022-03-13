import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en_us') +
      {
        'en_us': 'Address',
        'zh_cn': '地址',
      } +
      {
        'en_us': 'Download',
        'zh_cn': '下载',
      } +
      {
        'en_us': 'Upload',
        'zh_cn': '上传',
      } +
      {
        'en_us': 'Start Time',
        'zh_cn': '开始时间',
      } +
      {
        'en_us': '%s ago',
        'zh_cn': '%s前',
      } +
      {
        'en_us': 'Source Address',
        'zh_cn': '源地址',
      } +
      {
        'en_us': 'Destination IP',
        'zh_cn': '目的IP',
      } +
      {
        'en_us': 'Server(Protocol)',
        'zh_cn': '服务(协议)',
      };
  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
