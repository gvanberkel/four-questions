"""Render the Bron Hovi two-ring mark as web icons.

Geometry matches themes/bron_hovi_theme/lib/bron_hovi_mark.dart:
radius 0.28, stroke 0.11, centres offset +/-0.16 of the mark's side;
partner (sage) ring painted first, self (plum) ring on top.
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw

PAPER = (0xFA, 0xF7, 0xF4, 255)
PLUM = (0x55, 0x3C, 0x6E, 255)
SAGE = (0x5E, 0x94, 0x74, 255)
SS = 8  # supersampling factor


def ring(draw, cx, cy, r, stroke, color):
    outer = r + stroke / 2
    draw.ellipse((cx - outer, cy - outer, cx + outer, cy + outer),
                 outline=color, width=round(stroke))


def render(size, mark_scale, background='full', tile_radius=0.0):
    big = size * SS
    im = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if background == 'full':
        d.rectangle((0, 0, big, big), fill=PAPER)
    elif background == 'tile':
        d.rounded_rectangle((0, 0, big - 1, big - 1),
                            radius=big * tile_radius, fill=PAPER)
    side = big * mark_scale
    c = big / 2
    r = side * 0.28
    stroke = side * 0.11
    off = side * 0.16
    ring(d, c + off, c, r, stroke, SAGE)
    ring(d, c - off, c, r, stroke, PLUM)
    return im.resize((size, size), Image.LANCZOS)


def main(web_dir):
    web = Path(web_dir)
    render(32, 0.84, 'tile', tile_radius=0.22).save(web / 'favicon.png')
    for n in (192, 512):
        render(n, 0.80).convert('RGB').save(web / 'icons' / f'Icon-{n}.png')
        render(n, 0.60).save(web / 'icons' / f'Icon-maskable-{n}.png')
    print('wrote icons to', web)


if __name__ == '__main__':
    for target in sys.argv[1:]:
        main(target)
