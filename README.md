# 课表喵 TableMeow

Flutter 实现的课表应用，界面采用 Material 3 Expressive 设计。
支持登录教务系统导入课表、周课表显示、周次切换与今日课程时间轴。

## 功能

- **课表**：周视图网格，左侧是节次与上课时间，右侧每天一列，
  周末、节次列、周次条、网格线都可以在「设置 → 课表外观」里开关。
  左侧每节显示节次与开始 / 结束时间；今天所在列会高亮，正在上的那节课会画出一条时间线。
  每次回到应用都会自动跳回本周。
  顶部（或左右滑动）可切换周次、弹窗直选周次、一键回到本周。
  格子只显示课程名与地点（教师可选），字号全表统一；
  地点固定一行或按「楼名 / 房间号」拆成两行，房间号不会被拆开；
  教师、周次、节次时间点开详情查看。
  点击课程块查看课程详情，并可给这门课单独指定颜色与别名。
  课程块用 `StrutStyle` 把行高钉死，中文回退字体不会把格子撑破。
- **今日**：当天课程按节次排序，标注「进行中 / N 分钟后 / 已结束」，
  并显示当天日期与所属周次。
- **导入**：在应用内用 WebView 打开学校登录页，由用户自己完成登录。
  VPN 跳转、统一身份认证、验证码都不需要单独适配——
  用户先登 VPN 再登教务系统，或直接登教务系统都可以。
  登录后点「已完成登录，读取课表」，应用借用 WebView 里已有的会话
  请求正方 `xskbcx_cxXsKb.html` 拿到课表；接口读不到时会退化为
  解析当前页面已渲染的课表表格（含 `rowspan` 跨行课堂、强智的
  `2-11(周)` / `[01-02]节` 写法与带 `title` 的老师 / 教室字段）。
  单元格文本按 DOM 逐子节点拼接，各字段之间没有分隔符时也不会粘在一起。
  学年学期下拉框与课表表格都会连同源 iframe 一起找；课表表格按「星期列里
  写了周次或节次的格子数」打分挑选，不依赖各厂商的表格 id，也会避开
  「网课清单」这类没有排课信息的表格。
  页面上的「周次」只筛了某一周时，会按同一个表单再请求一次「全部」周次
  并取课程更多的那一份；实在取不到就在导入提示里说明，避免漏掉未开课周次的课程。
  密码只在登录页面里输入，应用不接触也不保存。
- **设置**：按分类列入口，点进去是各自的设置页。
  **课表**下有 **布局与尺寸**（每节高度自动 / 56–140dp、字号缩放 0.8–1.5×、
  行高紧凑 / 标准 / 宽松、列宽，以及周末 / 节次列 / 周次条 / 网格线开关）、
  **配色**（默认「跟随主题色」，课程块直接用主题配色的容器色，随主色与明暗自动协调；
  也可以切到自定义色板（Material / 马卡龙 / 莫兰迪 / 高对比）或单色，
  文字颜色自动 / 深 / 浅；单门课的颜色与别名在课程详情里设置）、
  **显示内容**（地点、教师、去掉教师职称、地点是否拆两行、课程名全名 / 别名）、
  **节次时间**（可按「上午 / 下午 / 晚上的开始时间 + 每节时长 + 课间休息」一键重排，也能逐节手改）与**学期设置**；
  **主题**（主色 —— 整套 Material 3 配色与课表颜色都由它推导，亮色 / 暗色 / 跟随系统、纯黑模式）；
  以及**数据管理**（课表数据量、清空课表、清除教务网页数据）与**关于**。
- 课表数据保存在本机（`shared_preferences`），启动后自动恢复。
- 配色以靛蓝为种子色推导（导航栏、按钮、卡片、输入框同一套色板），
  课程块只在蓝紫色相里取几个低饱和浅色。

## 目录结构

```
lib/
├── main.dart                       # 入口，只负责 runApp
├── app.dart                        # 应用根组件：主题 + 状态 + 主界面
├── models/
│   ├── period_time.dart            # 单节课的时间安排
│   ├── course_session.dart         # 一次上课安排（课程/星期/节次/周次）
│   ├── semester.dart               # 学期设置与周次、日期的换算
│   ├── timetable_style.dart        # 外观设置模型（布局 / 配色 / 显示 / 主题）
│   └── timetable.dart              # 课表聚合：查询、统计、序列化
├── data/
│   ├── timetable_storage.dart      # 持久化接口与实现
│   ├── demo_timetable.dart         # 示例课表（界面预览与测试用）
│   ├── timetable_text_parser.dart  # 「每行一条文本」解析（界面暂未提供入口）
│   └── jwxt/
│       ├── jwxt_web_scripts.dart   # 注入 WebView 的抓取脚本
│       ├── jwxt_bridge_result.dart # 脚本回传结果的模型
│       ├── jwxt_course_parser.dart # 正方课表字段与表格单元格解析
│       └── jwxt_login_store.dart   # 登录地址记忆
├── state/
│   ├── app_state.dart              # 课表数据、选中周次、持久化
│   └── app_scope.dart              # 状态的 InheritedNotifier 包装
├── navigation/
│   ├── app_destination.dart        # 底部导航入口清单
│   └── home_shell.dart             # 主界面外壳：底部导航栏 + 内容区
├── pages/
│   ├── timetable_page.dart         # 课表页
│   ├── today_page.dart             # 今日页
│   ├── import_page.dart            # 导入页
│   ├── webview_login_page.dart     # 网页登录页（WebView）
│   ├── settings_page.dart          # 设置首页（分类入口）
│   └── settings/                   # 设置子页：布局 / 配色 / 显示 / 主题 / 节次 / 学期 / 数据 / 关于
├── theme/
│   └── app_theme.dart              # Material 3 Expressive 主题
├── utils/
│   ├── date_format.dart            # 少量日期格式化
│   └── timeline.dart               # 课表时间线位置计算
└── widgets/
    ├── timetable_grid.dart         # 周课表网格
    ├── timetable_style_sections.dart # 外观设置的四组控件
    ├── week_selector.dart          # 周次选择条
    ├── course_detail_sheet.dart    # 课程详情弹窗
    ├── course_palette.dart         # 按课程名生成稳定配色
    ├── labeled_field.dart          # 标题独立在输入框上方的表单字段
    ├── page_scaffold.dart          # 内容页骨架
    ├── section_card.dart           # 带标题的区块卡片
    └── empty_state.dart            # 空状态占位
```

## 导航结构

界面使用底部导航栏（`NavigationBar`）承载四个页面：课表、今日、导入、设置。
内容区用 `IndexedStack` 承载，切换页面时各页状态（滚动位置、表单内容）都会保留；
导入完成后会自动跳回课表页。

## 新增一个页面

1. 在 `lib/pages/` 下新建页面文件。
2. 在 `lib/navigation/app_destination.dart` 的 `AppTab` 枚举与
   `appDestinations` 列表中追加入口。
3. 在 `lib/navigation/home_shell.dart` 的 `_pageOf` 中补一条分支。

页面顺序由 `appDestinations` 单一定义，导航栏与内容区都按它构建，
不需要手动对齐下标。

## 课表数据格式

导入的每条记录是「课程名 + 星期 + 节次 + 周次（+ 地点 + 教师）」。
星期支持 `1`、`周一`；节次支持 `1-2`、`第 3-4 节`、正方 `jcs` 的补零写法 `0102`；
周次支持 `1-16周`、`1,3,5-9周`、`2-14周(双)`、强智的 `2-11(周)`。

`lib/data/timetable_text_parser.dart` 还保留了「每行一条文本」的解析实现
（字段顺序：课程名, 星期, 节次, 周次, 地点, 教师），界面暂未提供入口，
解析逻辑由 `test/jwxt_parser_test.dart` 覆盖。

## 开发命令

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter test --update-goldens test/visual_preview_test.dart` 会重新生成
`test/goldens/` 下的界面预览图，用于人工核对排版。

## 已知限制

- 网页登录只在 Android / iOS 上可用（桌面端没有 WebView 实现，
  导入页会禁用按钮并给出提示）。
- 自动读取课表先尝试正方（`jwglxt`）的课表接口；接口不可用时改为解析当前页面上的课表表格。
  表格识别不依赖具体厂商：按「表头里的星期单元格数量」在页面（含同源 iframe）里挑最像课表的一张表，
  因此强智（学期理论课表）、URP 等没有固定表格 id 的系统也能走这条路径。
  强智把周次与节次写在单元格里（`2-11(周)`、`[01-02]节`），这些写法同样会被识别。
  少数页面结构特殊的学校可能仍需微调 `jwxt_web_scripts.dart`。
- 校外访问需要学校 VPN，先登 VPN 再登教务即可，两步都在同一个 WebView 里完成。
- 部分学校站点只提供 http，因此 Android 端开启了 `usesCleartextTraffic`。
- 时间线依赖设备本地时间，节次时间可在设置页按学校作息调整。
