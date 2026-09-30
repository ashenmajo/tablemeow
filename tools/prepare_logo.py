"""把收到的 logo 处理好放进工程资源。

处理三件事：

1. 按 alpha 外框裁掉透明留白；
2. **把图形在画布上左右居中**——图形本身可能不对称（比如书右侧的强调线），
   只按外框裁会让图形偏心，页头里就会看出"往右偏"；
3. 上方补透明像素成正方形、图形贴住底边，这样页头里用 bottomCenter
   就能既左右居中又贴底，不用在 Dart 里靠魔法位移去凑。
4. 缩到 256px（页头 88dp 容器，3x 屏约 264px，256 足够）并压缩体积。

用法（换 logo 时重跑一次）：
    python tools/prepare_logo.py <源图路径>
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "branding", "logo.png")

# 目标边长：页头容器 88dp，3x 屏约 264px，256 足够清晰又不会让资源变大。
TARGET = 256


# 判定"看得见"的 alpha 阈值。不能用 >0：导出的图边缘常有一圈几乎全透明的
# 噪声（alpha 只有个位数），按它取外框会把边界撑大、居中也就跟着偏。
VISIBLE_ALPHA = 128


def _centre_horizontally(im: Image.Image) -> Image.Image:
    """裁到可见内容的边界，再把图形在画布上左右居中。

    只按不透明外框裁是不够的：图形本身可能不对称，裁出来中心会落在
    画布中心之外，页头里一眼能看出"往右偏"。
    """
    mask = im.getchannel("A").point(lambda v: 255 if v >= VISIBLE_ALPHA else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise SystemExit("这张图没有可见像素，检查一下是不是导错了")
    content = im.crop(bbox)

    side = max(content.width, content.height)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    # 左右居中 + 底边贴住；上方补透明像素成正方形。
    canvas.alpha_composite(content, ((side - content.width) // 2, side - content.height))
    return canvas


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("用法: python tools/prepare_logo.py <源图路径>")

    im = Image.open(sys.argv[1]).convert("RGBA")
    im = _centre_horizontally(im)

    if TARGET < im.width:
        im = im.resize((TARGET, TARGET), Image.LANCZOS)

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    im.save(OUT, optimize=True)
    print(f"written  {OUT}  size={im.size}  {os.path.getsize(OUT) / 1024:.1f} KB")


if __name__ == "__main__":
    main()
