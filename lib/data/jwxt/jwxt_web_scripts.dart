import 'dart:convert';

/// 在 WebView 里执行、用来读取课表的脚本。
///
/// 脚本一律通过 [bridgeChannel] 把结果（JSON 字符串）回传给宿主，
/// 这样既能用异步请求，也不依赖脚本的返回值。
/// 每个回包都会带上调用方传入的 `token`，宿主据此丢弃迟到的旧结果。
abstract final class JwxtWebScripts {
  /// JS 与宿主之间的通道名。
  static const String bridgeChannel = 'TableMeowBridge';

  /// 脚本执行结果的状态字段取值。
  static const String statusOk = 'ok';
  static const String statusError = 'error';

  /// 数据来源：教务系统接口 / 当前页面已渲染的表格。
  static const String sourceApi = 'api';
  static const String sourceDocument = 'document';

  /// 读取课表：优先请求教务系统接口。
  ///
  /// 登录态来自 WebView 自身的 Cookie（含 VPN / SSO 跳转后的会话），
  /// 学年学期直接取当前页面上选中的那一组；页面上取不到时脚本会报错返回。
  ///
  /// [token] 会原样回传，用来区分不同次请求的回包。
  static String fetchTimetable({String token = ''}) {
    return _fetchTimetableTemplate
        .replaceAll('__CHANNEL__', bridgeChannel)
        .replaceAll('__TOKEN__', jsonEncode(token));
  }

  /// 抓取当前页面已经渲染出来的课表表格（接口读不到时的兜底）。
  ///
  /// 页面上的「周次」下拉框若不是「全部」，会顺带请求一次全部周次的结果，
  /// 避免只把当前这一周的课导进来。
  static String scrapeDocument({String token = ''}) =>
      _scrapeDocumentTemplate
          .replaceAll('__CHANNEL__', bridgeChannel)
          .replaceAll('__TOKEN__', jsonEncode(token));

  static const String _fetchTimetableTemplate = r'''
(function () {
  var post = function (payload) {
    payload.token = __TOKEN__;
    window.__CHANNEL__.postMessage(JSON.stringify(payload));
  };
  // 教务系统的课表页常常嵌在同源 iframe 里，
  // 学年学期的下拉框和课表表格都要连 iframe 一起找。
  var collectDocuments = function (root) {
    var documents = [root];
    var walk = function (doc, depth) {
      if (depth > 3) { return; }
      var frames = doc.querySelectorAll('iframe,frame');
      for (var i = 0; i < frames.length; i++) {
        var inner = null;
        try { inner = frames[i].contentDocument; } catch (e) { inner = null; }
        if (inner) {
          documents.push(inner);
          walk(inner, depth + 1);
        }
      }
    };
    walk(root, 0);
    return documents;
  };
  try {
    var documents = collectDocuments(document);
    var pick = function (selectors) {
      for (var d = 0; d < documents.length; d++) {
        for (var i = 0; i < selectors.length; i++) {
          var el = documents[d].querySelector(selectors[i]);
          if (el && el.value) { return String(el.value).trim(); }
        }
      }
      return '';
    };
    var xnm = pick(['#xnm', 'select[name="xnm"]', '#xnmBox']);
    var xqm = pick(['#xqm', 'select[name="xqm"]', '#xqmBox']);
    if (!xnm || !xqm) {
      post({status: 'error', message: '没有读取到学年学期，请先打开课表查询页面（正方「学生课表查询」/ 强智「学期理论课表」）'});
      return;
    }
    // 取最后一段模块目录：兼容 /jwglxt/xskbcx/... 与
    // /jsxsd/framework/... 这类「模块目录本身就是路径第一段」的部署。
    var matched = location.pathname.match(/^(.*)\/(xskbcx|xtgl|xsxkqk|kbjc|framework|jsxsd)\//);
    var prefix = matched ? matched[1] : '';
    var url = prefix + '/xskbcx/xskbcx_cxXsKb.html?gnmkdm=N253508';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) { return; }
      if (xhr.status === 0) {
        post({status: 'error', message: '请求课表接口失败，可能尚未登录或网络不通'});
        return;
      }
      if (xhr.status >= 400) {
        post({
          status: 'error',
          message: '课表接口返回 ' + xhr.status + '，请确认已登录并打开了「学生课表查询」页面'
        });
        return;
      }
      var text = (xhr.responseText || '').replace(/^\uFEFF/, '').replace(/^\s+/, '');
      if (text.slice(0, 4) === 'null') { text = '[]'; }
      if (text.charAt(0) !== '[' && text.charAt(0) !== '{') {
        post({status: 'error', message: '课表接口没有返回课表数据（正方以外的大多数系统需要改用页面表格读取），登录过期时也可能出现'});
        return;
      }
      post({
        status: 'ok',
        source: 'api',
        schoolYear: xnm,
        term: xqm,
        body: text
      });
    };
    xhr.onerror = function () {
      post({status: 'error', message: '请求课表接口出错，可能尚未登录或网络不通'});
    };
    xhr.send('xnm=' + encodeURIComponent(xnm) + '&xqm=' + encodeURIComponent(xqm));
  } catch (e) {
    post({status: 'error', message: '' + (e && e.message ? e.message : e)});
  }
})()
''';

  /// 表格抓取：
  ///
  /// 1. 在页面（含同源 iframe）里挑最像课表的表格，按 rowspan/colspan 取课程；
  /// 2. 页面上的「周次」下拉框若不是「全部」，再请求一次全部周次的结果，
  ///    取课程更多的那一份，避免漏掉当前周没开课的课程。
  static const String _scrapeDocumentTemplate = r'''
(function () {
  var post = function (payload) {
    payload.token = __TOKEN__;
    window.__CHANNEL__.postMessage(JSON.stringify(payload));
  };
  // 课表表格可能来自同源 iframe，逐个文档找。
  var collectDocuments = function (root) {
    var documents = [root];
    var walk = function (doc, depth) {
      if (depth > 3) { return; }
      var frames = doc.querySelectorAll('iframe,frame');
      for (var i = 0; i < frames.length; i++) {
        var inner = null;
        try { inner = frames[i].contentDocument; } catch (e) { inner = null; }
        if (inner) {
          documents.push(inner);
          walk(inner, depth + 1);
        }
      }
    };
    walk(root, 0);
    return documents;
  };
  // 逐个子节点拼文本，并在元素之间补一个换行。
  //
  // 强智等系统把课程名 / 教师 / 职称 / 周次 / 节次 / 教室各自装在一个
  // 元素里，元素之间却没有任何分隔符（换行是 CSS 排出来的），
  // 直接取 innerText 会得到「电磁场与电磁波侯周国副教授2-11(周)…」
  // 这样一整串，教师和教室就分不出来了。
  var rawTextOf = function (node) {
    var children = (node && node.childNodes) ? node.childNodes : null;
    if (!children || !children.length) {
      return (node && (node.innerText || node.textContent)) || '';
    }
    var out = '';
    for (var i = 0; i < children.length; i++) {
      var child = children[i];
      if (child.nodeType === 3) {
        out += child.nodeValue || '';
      } else if (child.nodeType === 1) {
        var tag = (child.tagName || '').toLowerCase();
        if (tag === 'br') {
          out += '\n';
          continue;
        }
        if (tag === 'script' || tag === 'style') { continue; }
        if (out && out.charAt(out.length - 1) !== '\n') { out += '\n'; }
        out += rawTextOf(child);
        out += '\n';
      }
    }
    return out;
  };
  var textOf = function (cell) {
    var raw = rawTextOf(cell);
    return raw.replace(/\u00a0/g, ' ')
      .replace(/[ \t]+/g, ' ')
      .replace(/\n\s*\n+/g, '\n')
      .trim();
  };
  // 强智等系统把教师 / 教室 / 周次节次放在带 title 的子元素里，
  // 这里把带 title 的字段单独取出来交给宿主。
  // 只取最内层的带 title 元素：外层容器一旦也带 title，
  // 它的内容就是整格文字，会把课程名和别的字段一起吞进去。
  var innerLabeled = function (root) {
    var all = root.querySelectorAll('[title]');
    var result = [];
    for (var i = 0; i < all.length; i++) {
      if (!all[i].querySelector('[title]')) { result.push(all[i]); }
    }
    return result;
  };
  var partsOf = function (cell) {
    var parts = [];
    var labeled = innerLabeled(cell);
    for (var i = 0; i < labeled.length; i++) {
      var title = (labeled[i].getAttribute('title') || '').replace(/\s/g, '');
      var value = textOf(labeled[i]);
      if (title && value) { parts.push(title + '\u0001' + value); }
    }
    return parts;
  };
  // 去掉带 title 的字段后剩下的文本就是课程名。
  var nameOf = function (cell) {
    var clone = null;
    try { clone = cell.cloneNode(true); } catch (e) { clone = null; }
    if (!clone) { return ''; }
    var labeled = innerLabeled(clone);
    for (var i = 0; i < labeled.length; i++) {
      if (labeled[i].parentNode) {
        labeled[i].parentNode.removeChild(labeled[i]);
      }
    }
    var raw = clone.textContent || '';
    return raw.replace(/\u00a0/g, ' ').replace(/\s+/g, ' ').trim();
  };
  var weekdayOf = function (text) {
    var t = (text || '').replace(/\s/g, '');
    var m = t.match(/(?:星期|周)([一二三四五六日天])/);
    if (m) {
      var names = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '日': 7, '天': 7};
      return names[m[1]] || 0;
    }
    var n = t.match(/^([1-7])$/);
    return n ? parseInt(n[1], 10) : 0;
  };
  var cnDigits = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9};
  var cnNumber = function (text) {
    if (!text) { return 0; }
    if (text.indexOf('十') < 0) { return cnDigits[text] || 0; }
    var parts = text.split('十');
    var tens = parts[0] ? (cnDigits[parts[0]] || 0) : 1;
    var ones = parts[1] ? (cnDigits[parts[1]] || 0) : 0;
    return tens * 10 + ones;
  };
  // 行首那一格可能是「第一节」「第一大节(01,02小节)」「上午1-2节」「1」
  // 「08:00-08:45」。强智按「大节」排，一个格子里写着两小节，例如
  // 「第三大节(05,06小节)」对应第 5-6 节，要取小节的起始号。
  // 时间是作息时间不是节次，识别不出时交给行号兜底。
  var periodOf = function (text) {
    var t = (text || '').replace(/\s/g, '');
    if (!t) { return 0; }
    var m = t.match(/(\d{1,2})[-~—,，](\d{1,2})小节/);
    if (m) { return parseInt(m[1], 10); }
    var cn = t.match(/第([一二三四五六七八九十]+)节/);
    if (cn) { return cnNumber(cn[1]); }
    m = t.match(/(\d{1,2})[-~—,，](\d{1,2})节/);
    if (m) { return parseInt(m[1], 10); }
    m = t.match(/(\d{1,2})节/);
    if (m) { return parseInt(m[1], 10); }
    if (/^\d{1,2}:\d{2}/.test(t)) { return 0; }
    m = t.match(/^(\d{1,2})(?!\d)/);
    return m ? parseInt(m[1], 10) : 0;
  };
  // 课表下面的「备注」行放的是没有排时间的课（例如课程设计），
  // 它横跨所有星期列，不该当成某一节来上。
  var isRemark = function (text) {
    var t = (text || '').replace(/\s/g, '');
    return t.indexOf('备注') === 0 || t.indexOf('说明') === 0 || t.indexOf('注:') === 0 || t.indexOf('注：') === 0;
  };
  // 真正排进课表的格子会写着周次或节次；「网课清单」这类表格不会。
  var looksScheduled = function (text) {
    var t = (text || '').replace(/\s/g, '');
    return t.indexOf('周') >= 0 || t.indexOf('节') >= 0;
  };
  // 各家的课表表格 id 都不一样（正方是 #kbtable，强智没有固定 id），
  // 所以不认 id：先要求表头有两列以上星期，再数一数「星期列里写了周次或
  // 节次的格子」。真正排进课表的课才有这些信息，而网课清单之类的表格
  // 只有课程名，靠这一点把它们区分开。
  var timetableScore = function (table) {
    var rows = table.querySelectorAll('tr');
    if (!rows || rows.length < 2) { return 0; }
    var scan = Math.min(rows.length, 5);
    var headerRow = -1;
    var headerMap = null;
    var weekdayCells = 0;
    for (var r = 0; r < scan; r++) {
      var rowCells = rows[r].querySelectorAll('th,td');
      var map = {};
      var found = 0;
      var col = 0;
      for (var c = 0; c < rowCells.length; c++) {
        var span = rowCells[c].colSpan || 1;
        var weekday = weekdayOf(textOf(rowCells[c]));
        if (weekday > 0) {
          for (var s = 0; s < span; s++) { map[col + s] = weekday; }
          found++;
        }
        col += span;
      }
      if (found > weekdayCells) {
        weekdayCells = found;
        headerMap = map;
        headerRow = r;
      }
    }
    if (weekdayCells < 2 || headerMap === null) { return 0; }
    var scheduledCells = 0;
    for (var r2 = headerRow + 1; r2 < rows.length; r2++) {
      var cells = rows[r2].querySelectorAll('th,td');
      var col2 = 0;
      for (var c2 = 0; c2 < cells.length; c2++) {
        var cellSpan = cells[c2].colSpan || 1;
        if (headerMap[col2] > 0 && looksScheduled(textOf(cells[c2]))) {
          scheduledCells++;
        }
        col2 += cellSpan;
      }
    }
    return scheduledCells * 1000 + weekdayCells * 10 + rows.length;
  };
  var findTable = function (documents) {
    var best = null;
    var bestScore = 0;
    for (var d = 0; d < documents.length; d++) {
      var tables = documents[d].querySelectorAll('table');
      for (var t = 0; t < tables.length; t++) {
        var score = timetableScore(tables[t]);
        if (score > bestScore) {
          bestScore = score;
          best = tables[t];
        }
      }
    }
    return best;
  };
  // 从一组文档里把课表读出来；读不到时返回带 message 的失败结果。
  var extractCourses = function (documents) {
    var table = findTable(documents);
    if (!table) {
      return {
        status: 'error',
        message: '当前页面没有找到课表表格，请先打开课表查询页面（正方「学生课表查询」/ 强智「学期理论课表」）'
      };
    }
    var rows = table.querySelectorAll('tr');
    // 表头行在前几行里挑「星期单元格最多」的一行，
    // 避免把某个课程名里带「周一」的数据行当成表头。
    var headerRow = -1;
    var headerMap = null;
    var bestCount = 0;
    var scanLimit = Math.min(rows.length, 5);
    for (var r = 0; r < scanLimit; r++) {
      var cells = rows[r].querySelectorAll('th,td');
      var map = {};
      var found = 0;
      var headerCol = 0;
      for (var c = 0; c < cells.length; c++) {
        var headerCell = cells[c];
        var headerSpan = headerCell.colSpan || 1;
        var weekday = weekdayOf(textOf(headerCell));
        if (weekday > 0) {
          for (var s = 0; s < headerSpan; s++) { map[headerCol + s] = weekday; }
          found++;
        }
        headerCol += headerSpan;
      }
      if (found > bestCount) {
        bestCount = found;
        headerMap = map;
        headerRow = r;
      }
    }
    if (headerMap === null || bestCount === 0) {
      return {status: 'error', message: '找到了课表表格，但没有识别出星期表头'};
    }

    var pending = {};
    var courses = [];
    for (var r2 = 0; r2 < rows.length; r2++) {
      var rowCells = rows[r2].querySelectorAll('th,td');
      var occupied = {};
      for (var key in pending) { if (pending[key] > 0) { occupied[key] = true; } }
      var rowPeriod = 0;
      var rowIsRemark = false;
      var placed = [];
      var col = 0;
      for (var i = 0; i < rowCells.length; i++) {
        var cell = rowCells[i];
        while (occupied[col]) { col++; }
        var colspan = cell.colSpan || 1;
        var rowspan = cell.rowSpan || 1;
        var text = textOf(cell);
        var mapped = headerMap[col];
        if (r2 > headerRow) {
          if (!mapped) {
            if (isRemark(text)) { rowIsRemark = true; }
            if (!rowPeriod) { rowPeriod = periodOf(text); }
          } else if (text) {
            if (isRemark(text)) {
              rowIsRemark = true;
            } else {
              placed.push({
                weekday: mapped,
                span: rowspan,
                text: text,
                name: nameOf(cell),
                parts: partsOf(cell)
              });
            }
          }
        }
        if (rowspan > 1) { pending[col] = (pending[col] || 0) + rowspan; }
        col += colspan;
      }
      for (var key2 in pending) {
        pending[key2] -= 1;
        if (pending[key2] <= 0) { delete pending[key2]; }
      }
      if (r2 > headerRow && !rowIsRemark) {
        if (!rowPeriod) { rowPeriod = r2 - headerRow; }
        for (var p = 0; p < placed.length; p++) {
          placed[p].period = rowPeriod;
          courses.push(placed[p]);
        }
      }
    }
    if (courses.length === 0) {
      return {status: 'error', message: '课表表格里没有读到课程，可能是空课表或页面结构不同'};
    }
    return {status: 'ok', source: 'document', courses: courses};
  };
  // 页面上的「周次」下拉框：如果它只筛了某一周，就拼一次表单请求去取
  // 「全部」周次的结果，避免漏掉当前周没开课的课程。
  //
  // 返回 null 表示没有周次过滤（或已经是全部）；
  // 返回 {warning} 表示过滤了但没法自动补齐。
  var weekFilterOf = function (documents) {
    for (var d = 0; d < documents.length; d++) {
      var selects = documents[d].querySelectorAll('select');
      for (var i = 0; i < selects.length; i++) {
        var el = selects[i];
        if (!el.options || el.options.length < 2) { continue; }
        var allValue = null;
        var weekLike = 0;
        var otherLike = 0;
        for (var o = 0; o < el.options.length; o++) {
          var option = el.options[o];
          var text = (option.text || '').replace(/\s/g, '');
          var value = String(option.value);
          if (value === '0' || text.indexOf('全部') >= 0 || text.indexOf('所有') >= 0) {
            if (allValue === null) { allValue = value; }
          } else if (/^\d+$/.test(value) || text.indexOf('周') >= 0) {
            weekLike++;
          } else {
            otherLike++;
          }
        }
        // 只认「看起来是周次」的下拉框，别把学期、节次模式之类的选错。
        if (weekLike < 2 || otherLike > weekLike) { continue; }
        var selected = el.options[el.selectedIndex];
        var label = selected
          ? String(selected.text).replace(/\s/g, '')
          : ('第 ' + String(el.value) + ' 周');
        if (allValue !== null && String(el.value) === allValue) { return null; }
        if (allValue === null || !el.form) {
          return {
            warning: '页面当前只显示了' + label +
              '，请在课表页面把「周次」切到「全部」后重新读取，否则未开课周次的课程会缺失'
          };
        }
        return weekRequestOf(el, allValue, label);
      }
    }
    return null;
  };
  var weekRequestOf = function (select, allValue, label) {
    var form = select.form;
    var pairs = [];
    var fields = form.elements || [];
    for (var f = 0; f < fields.length; f++) {
      var field = fields[f];
      if (!field.name || field.disabled) { continue; }
      var type = (field.type || '').toLowerCase();
      if (type === 'submit' || type === 'button' || type === 'reset' || type === 'file') { continue; }
      if ((type === 'checkbox' || type === 'radio') && !field.checked) { continue; }
      var value = (field === select) ? allValue : (field.value == null ? '' : field.value);
      pairs.push(encodeURIComponent(field.name) + '=' + encodeURIComponent(value));
    }
    var body = pairs.join('&');
    var method = (form.method || 'get').toUpperCase();
    var action = form.action || location.href;
    if (method === 'GET') {
      return {
        label: label,
        request: {
          method: 'GET',
          url: action + (action.indexOf('?') >= 0 ? '&' : '?') + body,
          body: ''
        }
      };
    }
    return {label: label, request: {method: 'POST', url: action, body: body}};
  };
  // 两份结果里取课程更多的那一份。
  var betterOf = function (a, b) {
    if (!b || b.status !== 'ok') { return a; }
    if (a.status !== 'ok') { return b; }
    return (b.courses || []).length > (a.courses || []).length ? b : a;
  };
  window.setTimeout(function () {
    try {
      var documents = collectDocuments(document);
      var current = extractCourses(documents);
      var info = weekFilterOf(documents);
      if (!info || !info.request) {
        if (info && info.warning) { current.warning = info.warning; }
        post(current);
        return;
      }
      var fallbackWarning =
        '页面当前只显示了' + info.label + '，未能读到全部周次，未开课周次的课程可能缺失';
      var xhr = new XMLHttpRequest();
      xhr.open(info.request.method, info.request.url, true);
      if (info.request.method === 'POST') {
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
      }
      xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      var done = false;
      var settle = function (result, warning) {
        if (done) { return; }
        done = true;
        if (warning) { result.warning = warning; }
        post(result);
      };
      var timer = window.setTimeout(function () { settle(current, fallbackWarning); }, 9000);
      xhr.onreadystatechange = function () {
        if (done || xhr.readyState !== 4) { return; }
        window.clearTimeout(timer);
        var full = null;
        try {
          if (xhr.status >= 200 && xhr.status < 400 && xhr.responseText) {
            var doc = new DOMParser().parseFromString(xhr.responseText, 'text/html');
            if (doc && doc.querySelector) { full = extractCourses([doc]); }
          }
        } catch (e) {
          full = null;
        }
        var merged = betterOf(current, full);
        settle(merged, merged === full ? '' : fallbackWarning);
      };
      xhr.onerror = function () {
        window.clearTimeout(timer);
        settle(current, fallbackWarning);
      };
      xhr.send(info.request.method === 'POST' ? info.request.body : null);
    } catch (e) {
      post({status: 'error', message: '' + (e && e.message ? e.message : e)});
    }
  }, 0);
})()
''';
}
