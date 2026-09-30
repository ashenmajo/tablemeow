"""校验注入 WebView 的抓取脚本。

它是 r'''...''' 原始字符串，所以 Dart 源码里的字节就是运行时注入的字节
（只替换 __TOKEN__ / __CHANNEL__）。于是可以直接抽出来做三层校验：

1. 语法：node --check，防止手改 JS 把括号引号写坏；
2. 占位符：确认两个占位符都被替换掉了；
3. 行为：配一个小 DOM 桩，把整段脚本真跑一遍，检查「周次下拉」的识别与报警策略。

行为用例里的 B 用的是真机上出现的形状：一个值是 2026-09-28、选中项文字是
「第四周」的「当前周 / 日期」选择器 —— 它正是之前那条误报的元凶。

用法：
    python tools/check_jwxt_scripts.py
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "lib", "data", "jwxt", "jwxt_web_scripts.dart")
OUT_DIR = os.path.join(ROOT, "build")

START = "_scrapeDocumentTemplate = r'''"
END = "''';"

SUBSTITUTIONS = {
    "__CHANNEL__": "TableMeowBridge",
    # 模板里是 payload.token = __TOKEN__;（不带引号），所以要替换成一个 JS 字符串字面量。
    "__TOKEN__": "'check-token'",
}

# ---------------------------------------------------------------- 行为用例

CASES = r"""
var DATE_OPTIONS = [
  ['第四周', '2026-09-28'], ['第五周', '2026-10-05'], ['第六周', '2026-10-12'],
  ['第七周', '2026-10-19'], ['第八周', '2026-10-26'], ['第九周', '2026-11-02']
];
var WEEK_OPTIONS = [
  ['全部', '0'], ['第1周', '1'], ['第2周', '2'], ['第3周', '3'], ['第4周', '4']
];

function selectOf(options, selectedIndex) {
  return makeSelect({ options: options, selectedIndex: selectedIndex || 0 });
}

var results = [];

// B：真机形状 —— 页面上只有那个「当前周 / 日期」选择器。
// 它既不该被当成周次下拉，也不该给用户弹提示（只在控制台留一行）。
results.push(check('B 只有日期选择器（真机形状）',
  [selectOf(DATE_OPTIONS, 0)], '', true));

// C：真的有个周次下拉且选在「全部」-> 当前页面就是全量，不提示也不重读。
results.push(check('C 周次下拉选在「全部」',
  [selectOf(DATE_OPTIONS, 0), selectOf(WEEK_OPTIONS, 0)], '', false));

// D：周次下拉选在「第2周」-> 应带「全部」重发请求；XHR 桩永不回调，
//    所以走 9 秒兜底，必须给出「超时」提示（失败是真话，不能静默）。
results.push(check('D 周次下拉选在第2周（重读超时）',
  [selectOf(DATE_OPTIONS, 0), selectOf(WEEK_OPTIONS, 1)], '超时', false));

var pass = 0;
for (var i = 0; i < results.length; i++) {
  if (results[i].ok) { pass++; }
  console.log('  ' + (results[i].ok ? 'ok  ' : 'FAIL') + ' ' + results[i].text);
}
console.log('行为校验 ' + (pass === results.length ? '通过' : '失败') +
  ' (' + pass + '/' + results.length + ')');
if (pass !== results.length) { process.exit(1); }

function check(name, selects, wantWarningSubstring, wantConsoleWarn) {
  var env = __runScrape(selects);
  var payload = env.payload || {};
  var warning = payload.warning || '';
  var problems = [];
  if (wantWarningSubstring === '') {
    if (warning !== '') { problems.push('不该有提示，却得到「' + warning + '」'); }
  } else if (warning.indexOf(wantWarningSubstring) < 0) {
    problems.push('提示里应含「' + wantWarningSubstring + '」，实际「' + warning + '」');
  }
  var warned = env.warnings.length > 0;
  if (warned !== wantConsoleWarn) {
    problems.push('console.warn 期望 ' + wantConsoleWarn + '，实际 ' + warned);
  }
  var text = name + ' -> warning="' + warning + '" console.warn=' + warned +
    ' 课程数=' + (payload.courses ? payload.courses.length : 0);
  if (problems.length) { text += '  [' + problems.join('；') + ']'; }
  return { ok: problems.length === 0, text: text };
}
"""

# ---------------------------------------------------------------- DOM 桩

SHIM = r"""
// 只实现脚本真正用到的接口。
// querySelectorAll('table') 返回空数组 -> extractCourses 走 status:'error'、
// courses: []，这条路径能跑通，不必造出整张课表。
// setTimeout 立即执行，避免测试真的等 9 秒。
// XMLHttpRequest 桩成「永不回调」，用来走超时兜底分支。
function makeSelect(spec) {
  var el = {
    options: [],
    selectedIndex: spec.selectedIndex || 0,
    form: null,
    parentNode: null,
    textContent: '',
    querySelectorAll: function () { return []; }
  };
  for (var i = 0; i < spec.options.length; i++) {
    el.options.push({ text: spec.options[i][0], value: spec.options[i][1] });
  }
  // 真实 <select> 的 value 就是选中项的值，不要人为造出不一致。
  el.value = el.options[el.selectedIndex].value;
  return el;
}
"""

HARNESS = """
var __state = { posted: null, warnings: [], selects: [] };
var document = {
  querySelectorAll: function (sel) { return sel === 'select' ? __state.selects : []; }
};
var location = { href: 'http://jw.example/kb' };
// 脚本里有的是 window.xxx，有的是裸 xxx（如 new XMLHttpRequest()），两边都要给。
function __FakeXhr() {
  this.open = function () {};
  this.setRequestHeader = function () {};
  this.send = function () {};
}
function __FakeDomParser() {
  this.parseFromString = function () {
    return {
      querySelector: function () { return null; },
      querySelectorAll: function () { return []; }
    };
  };
}
var window = {
  // SUBSTITUTIONS 已把 __CHANNEL__ 换成 TableMeowBridge。
  TableMeowBridge: {
    postMessage: function (msg) { __state.posted = msg; }
  },
  setTimeout: function (fn) { fn(); return 0; },
  clearTimeout: function () {},
  getComputedStyle: function () { return { display: 'block' }; },
  console: { warn: function (m) { __state.warnings.push(m); }, log: function () {} },
  XMLHttpRequest: __FakeXhr,
  DOMParser: __FakeDomParser
};
// 裸全局：脚本里 new XMLHttpRequest() / new DOMParser() 用的是这两个。
var XMLHttpRequest = __FakeXhr;
var DOMParser = __FakeDomParser;

function __runScrape(selects) {
  __state.posted = null;
  __state.warnings = [];
  for (var i = 0; i < selects.length; i++) {
    if (!selects[i].form) {
      selects[i].form = {
        method: 'post',
        action: 'http://jw.example/kb',
        elements: [selects[i], { name: 'xnm', value: '2026', type: 'text' }]
      };
    }
  }
  __state.selects = selects;
  __SCRAPE_SCRIPT__
  // 脚本 postMessage 的是消息对象本身（JSON 字符串），不是 {token, payload} 外层结构，
  // 与 Dart 侧 JwxtBridgeResult.tryDecode 读顶层字段一致。
  return {
    payload: __state.posted ? JSON.parse(__state.posted) : null,
    warnings: __state.warnings
  };
}
__SHIM__
__CASES__
"""


def extract_script() -> str:
    with open(SRC, encoding="utf-8") as handle:
        source = handle.read()
    start = source.index(START) + len(START)
    end = source.index(END, start)
    script = source[start:end]
    for key, value in SUBSTITUTIONS.items():
        script = script.replace(key, value)
    return script


def run_node(args, label):
    result = subprocess.run(
        args,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )
    if result.stdout:
        sys.stdout.write(result.stdout)
    if result.returncode != 0:
        print(f"{label}失败：")
        sys.stderr.write(result.stderr or "")
        return False
    return True


def check_syntax(script: str) -> bool:
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, "jwxt_scrape_check.js")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(script)
    if not run_node(["node", "--check", path], "语法校验"):
        return False
    print(f"语法校验通过  ({len(script)} 字节，占位符已全部替换)")
    return True


def build_harness(script: str, cases: str) -> str:
    """把抓取脚本与桩、用例拼成一个可执行的 JS 文件内容。

    顺序很重要：先塞脚本，再塞桩与用例，否则用例里的同名占位符会被一起替换掉。
    """
    return (
        HARNESS.replace("__SCRAPE_SCRIPT__", script)
        .replace("__SHIM__", SHIM)
        .replace("__CASES__", cases)
    )


def check_behaviour(script: str) -> bool:
    harness = build_harness(script, CASES)
    path = os.path.join(OUT_DIR, "jwxt_behaviour_check.js")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(harness)
    return run_node(["node", path], "行为校验")


def main() -> None:
    script = extract_script()
    if "__TOKEN__" in script or "__CHANNEL__" in script:
        raise SystemExit("还有没替换掉的占位符，检查 SUBSTITUTIONS")

    ok = check_syntax(script)
    print("行为校验：")
    ok = check_behaviour(script) and ok
    if not ok:
        raise SystemExit(1)
    print("全部通过")


if __name__ == "__main__":
    main()
