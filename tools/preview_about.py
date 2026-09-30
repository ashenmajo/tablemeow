"""把 test/goldens 里的「关于」页截图拼成一张对比图。

出图流程（截图由临时的 golden 测试生成，出图后测试与 test/goldens 都会删掉）：

    flutter test test/about_verify_test.dart --update-goldens
    python tools/preview_about.py

注意：资源图是异步解码的，golden 测试里要显式等图片解码完成
（用 tester.runAsync + delay），否则会抓到「图还没画上去」的空页头。
"""
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(ROOT, "test", "goldens")
OUT = os.path.join(ROOT, "build", "about_preview.png")

# (文件名, 列标题)
ITEMS = [
    ("final_light.png", "关于 · 浅色"),
    ("final_dark.png", "关于 · 深色"),
]
ROW_LABELS: list[str] = []  # 只有一行时不需要行标签
COLUMNS = 2
SCALE = 0.78
BAR = 40
PAD = 16
ROW_H = 22

# 标签里有中文，默认位图字体画不出来，优先用系统中文字体。
LABEL_FONT_CANDIDATES = [
    (r"C:\Windows\Fonts\msyh.ttc", 0),
    (r"C:\Windows\Fonts\Deng.ttf", 0),
]


def _label_font(size: int) -> ImageFont.ImageFont:
    for path, index in LABEL_FONT_CANDIDATES:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size, index=index)
            except OSError:
                continue
    return ImageFont.load_default()


def main() -> None:
    tiles = []
    for name, label in ITEMS:
        im = Image.open(os.path.join(BASE, name)).convert("RGB")
        im = im.resize((int(im.width * SCALE), int(im.height * SCALE)), Image.LANCZOS)
        tiles.append((im, label))

    tw = max(im.width for im, _ in tiles)
    th = max(im.height for im, _ in tiles)
    rows = (len(tiles) + COLUMNS - 1) // COLUMNS

    width = COLUMNS * (tw + PAD) + PAD
    height = rows * (th + BAR + PAD) + PAD
    canvas = Image.new("RGB", (width, height), (24, 24, 28))
    draw = ImageDraw.Draw(canvas)
    small = _label_font(15)
    big = _label_font(17)

    for index, (im, label) in enumerate(tiles):
        row, col = divmod(index, COLUMNS)
        x = PAD + col * (tw + PAD)
        y = PAD + row * (th + BAR + PAD)
        if ROW_LABELS:
            draw.text(
                (x, y),
                f"设计方向 · {ROW_LABELS[row]}",
                font=small,
                fill=(150, 150, 160),
            )
        draw.text((x, y + ROW_H), label, font=big, fill=(240, 240, 246))
        canvas.paste(im, (x, y + BAR))

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    canvas.save(OUT)
    print(OUT, canvas.size)


if __name__ == "__main__":
    main()
