"""读教务系统导出的 .xls 课表，打印出完整的课程/周次清单。

用途：把它当作「标准答案」，和 App 里「课表数据」页显示的内容对比，
判断导入是否真的漏了课程或周次。

用法：
    python tools/read_exported_xls.py <导出的 xls 路径>
"""
import sys

import xlrd


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("用法: python tools/read_exported_xls.py <xls 路径>")

    book = xlrd.open_workbook(sys.argv[1], formatting_info=False)
    print(f"工作表: {book.sheet_names()}")
    for sheet in book.sheets():
        print(f"--- {sheet.name}  {sheet.nrows} 行 x {sheet.ncols} 列 ---")
        for r in range(sheet.nrows):
            cells = []
            for c in range(sheet.ncols):
                value = sheet.cell_value(r, c)
                if isinstance(value, float) and value == int(value):
                    value = int(value)
                text = str(value).replace("\n", " ⏎ ").strip()
                if text:
                    cells.append(f"[{c}]{text}")
            if cells:
                print(f"r{r}: " + " | ".join(cells))


if __name__ == "__main__":
    main()
