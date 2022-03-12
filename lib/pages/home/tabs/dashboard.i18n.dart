import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en_us') +
      {
        'en_us': 'Total download',
        'zh_cn': '总下载',
      } +
      {
        'en_us': 'Total upload',
        'zh_cn': '总上传',
      } +
      {
        'en_us': 'Download speed',
        'zh_cn': '下载速度',
      } +
      {
        'en_us': 'Upload speed',
        'zh_cn': '上传速度',
      } +
      {
        'en_us': 'Connections',
        'zh_cn': '连接',
      };
  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
