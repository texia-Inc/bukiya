# Draws the app icon and launch screen into the Xcode asset catalog. Run after prepare.py (it uses the fonts it downloads).
#   icon:   summer sky, sun, sea with a wave line, the title kanji and a little skateboard
#   splash: the page's background colour with the title, so the launch flows straight into the game's own title screen
import os
from PIL import Image, ImageDraw, ImageFont
here = os.path.dirname(os.path.abspath(__file__))
assets = os.path.join(here, 'ios', 'App', 'App', 'Assets.xcassets')
deco = os.path.join(here, '.cache', 'KaiseiDecol-Bold.ttf')
maru = os.path.join(here, '.cache', 'ZenMaruGothic-Black.ttf')
INK, PAPER, SEA, DEEP, SUN, ROSE = (43, 37, 32), (255, 250, 240), (31, 127, 192), (20, 90, 140), (242, 163, 58), (226, 88, 74)

def icon():
    N = 1024
    im = Image.new('RGB', (N, N))
    d = ImageDraw.Draw(im)
    for y in range(N):  # sky to pale horizon
        t = y / 620
        d.line([(0, y), (N, y)], fill=tuple(int(a + (b - a) * min(t, 1)) for a, b in zip((120, 196, 236), (214, 238, 248))))
    d.ellipse((640, 110, 880, 350), fill=SUN)
    d.rectangle((0, 620, N, N), fill=SEA)
    for i, y in enumerate((700, 800, 900)):  # wave lines
        pts = [(x, y + 14 * __import__('math').sin(x / 60 + i)) for x in range(0, N + 8, 8)]
        d.line(pts, fill=(255, 255, 255) if i == 0 else (90, 170, 220), width=10 - i * 2)
    d.rectangle((0, 960, N, N), fill=DEEP)
    f = ImageFont.truetype(deco, 460)
    d.text((N // 2 + 8, 470 + 10), '海', font=f, anchor='mm', fill=(20, 70, 110))
    d.text((N // 2, 470), '海', font=f, anchor='mm', fill=PAPER, stroke_width=14, stroke_fill=INK)
    # skateboard: deck with kicked tails and two wheels
    d.rounded_rectangle((250, 768, 774, 818), radius=25, fill=ROSE, outline=INK, width=10)
    for x in (360, 664):
        d.ellipse((x - 42, 812, x + 42, 896), fill=PAPER, outline=INK, width=10)
    im.save(os.path.join(assets, 'AppIcon.appiconset', 'AppIcon-512@2x.png'))

def splash():
    N = 2732
    im = Image.new('RGB', (N, N), (207, 232, 245))
    d = ImageDraw.Draw(im)
    d.text((N // 2, N // 2 - 40), '海街スケート', font=ImageFont.truetype(deco, 150), anchor='mm', fill=INK)
    d.text((N // 2, N // 2 + 110), 'Umimachi Skate', font=ImageFont.truetype(maru, 64), anchor='mm', fill=(107, 95, 85))
    for n in ('splash-2732x2732.png', 'splash-2732x2732-1.png', 'splash-2732x2732-2.png'):
        im.save(os.path.join(assets, 'Splash.imageset', n))

icon(); splash(); print('icons ready')
