"""把今日页课程卡在「长课名 + 长状态文案」下的候选方案拼成对比图。

    flutter test test/today_card_preview_test.dart --update-goldens
    flutter test test/today_long_preview_test.dart --update-goldens
    python tools/preview_today_cards.py
"""
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(ROOT, "test", "goldens")
OUT = os.path.join(ROOT, "build", "today_cards.png")

# 上半段用短课名区分方案外形，下半段用 18 字长课名验证极端情况。
ITEMS = [
    ("card_now.png", "现状 · 短课名", None),
    ("card_a.png", "方案 1 · 状态独占第二行", None),
    ("card_c.png", "方案 3 · 倒计时进时间列（需加宽）", None),
    ("card_d.png", "方案 4 · 左侧色条表状态", None),
    ("long_v1.png", "方案 2 · 右侧胶囊限宽", "18 字长课名：名字与状态双双被截断 —— 不可行"),
    ("long_v2.png", "方案 1 · 状态独占第二行", "18 字长课名：名字、状态、详情全部完整显示"),
    ("long_v3.png", "方案 3 · 倒计时进时间列", "18 字长课名：倒计时在 62dp 列里折行，需加宽或缩短文案"),
]

LABEL_FONT_CANDIDATES = [
    (r"C:\Windows\Fonts\msyh.ttc", 0),
    (r"C:\Windows\Fonts\Deng.ttf", 0),
]

PAD = 14
LABEL_H = 24
NOTE_H = 22


def _font(size: int) -> ImageFont.ImageFont:
    for path, index in LABEL_FONT_CANDIDATES:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size, index=index)
            except OSError:
                continue
    return ImageFont.load_default()


def _trim(im: Image.Image) -> Image.Image:
    rgb = im.convert("RGB")
    bg = rgb.getpixel((3, 3))
    bottom = rgb.height
    for y in range(rgb.height - 1, 0, -1):
        row = [rgb.getpixel((x, y)) for x in range(0, rgb.width, 4)]
        if any(
            abs(p[0] - bg[0]) + abs(p[1] - bg[1]) + abs(p[2] - bg[2]) > 12 for p in row
        ):
            bottom = min(rgb.height, y + 14)
            break
    return rgb.crop((0, 0, rgb.width, bottom))


def main() -> None:
    tiles = []
    for name, label, note in ITEMS:
        tiles.append((_trim(Image.open(os.path.join(BASE, name))), label, note))

    width = max(im.width for im, _, _ in tiles) + PAD * 2
    height = sum(
        im.height + LABEL_H + (NOTE_H if note else 0) + PAD for im, _, note in tiles
    ) + PAD
    canvas = Image.new("RGB", (width, height), (24, 24, 28))
    draw = ImageDraw.Draw(canvas)
    title_font = _font(17)
    note_font = _font(15)

    y = PAD
    for im, label, note in tiles:
        draw.text((PAD, y), label, font=title_font, fill=(240, 240, 246))
        y += LABEL_H
        if note:
            draw.text((PAD, y), note, font=note_font, fill=(150, 190, 255))
            y += NOTE_H
        canvas.paste(im, (PAD, y))
        y += im.height + PAD

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    canvas.save(OUT)
    print(OUT, canvas.size)


if __name__ == "__main__":
    main()
