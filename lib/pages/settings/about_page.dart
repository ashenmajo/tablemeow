///about.dart
///该文件是关于页：应用的封面、技术信息、隐私说明与开源许可
library;

import 'package:flutter/material.dart';

import '../../app_info.dart';
import '../../theme/brand.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import 'data_settings_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String appVersion = AppInfo.version;

  static const String _logoAsset = 'assets/branding/logo.png';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: PageScaffold(
        children: <Widget>[
          _buildIdentity(theme),
          SectionCard(
            title: '软件信息',
            icon: Icons.widgets_outlined,
            child: Column(
              children: <Widget>[
                const _InfoRow(label: '应用名称', value: 'TableMeow（课表喵）'),
                const Divider(height: 1),
                const _InfoRow(label: '版本', value: appVersion),
                const Divider(height: 1),
                const _InfoRow(
                  label: '界面',
                  value: 'Flutter · Material 3 Expressive',
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('开源许可'),
                  subtitle: const Text('查看所用开源库的许可证'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openLicenses(context),
                ),
              ],
            ),
          ),
          SectionCard(
            title: '隐私',
            icon: Icons.lock_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '课表、学期设置与外观设置都只保存在本机。'
                  '登录教务系统时密码只在学校的登录页面里输入，'
                  '应用不接触也不保存。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '登录教务系统时产生的网页缓存可以随时清除。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DataSettingsPage(),
                      ),
                    ),
                    icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                    label: const Text('前往数据管理'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentity(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
      child: Column(
        children: <Widget>[
          Semantics(
            label: 'TableMeow 应用图标',
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Brand.indigo,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  _logoAsset,
                  width: 76,
                  fit: BoxFit.fitWidth,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('TableMeow', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '一个简单快速的课表应用',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static void _openLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'TableMeow',
      applicationVersion: appVersion,
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Brand.indigo,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(_logoAsset, width: 40, fit: BoxFit.fitWidth),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
