import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations('en_us') +
      {
        'en_us': 'Add Server',
        'zh_cn': '新服务器',
      } +
      {
        'en_us': 'Select a Server',
        'zh_cn': '选择服务器',
      } +
      {
        'en_us': 'Edit Server',
        'zh_cn': '编辑服务器',
      } +
      {
        'en_us': 'Remove Server',
        'zh_cn': '删除服务器',
      } +
      {
        'en_us': 'Are you sure to remove %s? This action cannot be undone.',
        'zh_cn': '确定要删除 %s 吗？此操作不可撤销。',
      } +
      {
        'en_us': 'Cancel',
        'zh_cn': '取消',
      } +
      {
        'en_us': 'Remove',
        'zh_cn': '删除',
      } +
      {
        'en_us': 'Add',
        'zh_cn': '新增',
      } +
      {
        'en_us': 'Server URL',
        'zh_cn': '服务器地址',
      } +
      {
        'en_us': 'Please enter URL',
        'zh_cn': '请输入服务器地址',
      } +
      {
        'en_us': 'Description',
        'zh_cn': '描述',
      } +
      {
        'en_us': 'Server1',
        'zh_cn': '服务器1',
      } +
      {
        'en_us': 'Token',
        'zh_cn': '令牌',
      } +
      {
        'en_us': 'A very secret token',
        'zh_cn': '一个非常机密的令牌',
      } +
      {
        'en_us': 'No server. Add one?',
        'zh_cn': '没有服务器，新增一个吗？',
      };
  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}
