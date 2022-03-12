import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en_us') +
      {
        'en_us': 'Dashboard',
        'zh_cn': '仪表盘',
      } +
      {
        'en_us': 'Config',
        'zh_cn': '配置',
      } +
      {
        'en_us': 'Connections',
        'zh_cn': '连接',
      };
  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
