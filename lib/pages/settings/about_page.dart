///about.dart
///该文件是关于页，没什么好说的，就是说明一下软件的设计框架以及相关开发信息
library;

import 'package:flutter/material.dart';

import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: PageScaffold(
        children: <Widget>[
          SectionCard(
            title: 'TableMeow',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('版本 1.0.0', style: theme.textTheme.bodyMedium),
                Text(
                  'Flutter Material Designed 3',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          SectionCard(
            title: '隐私',
            icon: Icons.lock_outline,
            child: Text(
              '课表、学期设置与外观设置都只保存在本机。'
              '登录教务系统时密码只在学校的登录页面里输入，'
              '应用不接触也不保存。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
