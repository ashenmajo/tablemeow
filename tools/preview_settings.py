"""拼一张「设置页入口 → 关于页」的流程图，用于确认改动效果。

    flutter test test/settings_verify_test.dart --update-goldens
    python tools/preview_settings.py
"""
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.path.join(ROOT, "test", "goldens")
OUT = os.path.join(ROOT, "build", "settings_preview.png")

ITEMS = [
    ("settings_light.png", "设置（「关于」不再是卡片）"),
    ("about_light.png", "关于页"),
]
COLUMNS = 2
SCALE = 0.72
BAR = 40
PAD = 16
ROW_H = 22

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
    big = _label_font(17)

    for index, (im, label) in enumerate(tiles):
        row, col = divmod(index, COLUMNS)
        x = PAD + col * (tw + PAD)
        y = PAD + row * (th + BAR + PAD)
        draw.text((x, y + ROW_H), label, font=big, fill=(240, 240, 246))
        canvas.paste(im, (x, y + BAR))

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    canvas.save(OUT)
    print(OUT, canvas.size)


if __name__ == "__main__":
    main()
